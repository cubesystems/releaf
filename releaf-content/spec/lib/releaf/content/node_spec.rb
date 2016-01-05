require "rails_helper"

describe Node do
  class PlainNode < ActiveRecord::Base
    include Releaf::Content::Node
    self.table_name = "nodes"
  end

  let(:plain_subject){ PlainNode.new }

  it { is_expected.to accept_nested_attributes_for(:content) }
  it { is_expected.to belong_to(:content) }

  it "includes Releaf::Content::Node module" do
    expect( Node.included_modules ).to include Releaf::Content::Node
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_presence_of(:content_type) }
    it { is_expected.to validate_uniqueness_of(:slug).scoped_to(:parent_id) }
    it { is_expected.to validate_length_of(:name).is_at_most(255) }
    it { is_expected.to validate_length_of(:slug).is_at_most(255) }
  end

  describe "after save" do
    it "sets node update to current time" do
      expect( Node ).to receive(:updated).once
      create(:node)
    end
  end

  describe ".active (scope)" do
    it "returns active nodes" do
      expect( Node ).to receive(:where).with(active: true).and_return('foo')
      expect( Node.active ).to eq 'foo'
    end
  end

  describe "#content_class" do
    context 'when #content_type is nil' do
      it 'returns nil' do
        subject.content_type = nil
        expect( subject.content_class ).to be_nil
      end
    end

    context "when #content_type is blank string" do
      it 'returns nil' do
        subject.content_type = ""
        expect( subject.content_class ).to be_nil
      end
    end

    context "when #content_type is not blank" do
      it "constantizes it" do
        subject.content_type = "Node"
        expect( subject.content_class ).to eq Node
      end
    end
  end

  describe "#to_s" do
    it "returns name" do
      expect(subject.to_s).to eq(subject.name)
    end
  end

  describe "#locale" do
    before do
      root = create(:node, locale: "lv")
      parent = create(:text_page_node, locale: nil, parent_id: root.id)
      @child1 = create(:text_page_node, locale: nil, parent_id: parent.id)
      @child2 = create(:text_page_node, parent_id: parent.id, locale: "en")
    end

    context "when node locale is nil" do
      it "uses closest parent locale" do
        expect(@child1.locale).to eq("lv")
      end
    end

    context "when object node have locale" do
      it "uses closest parent locale" do
        expect(@child2.locale).to eq("en")
      end
    end
  end

  describe "#destroy" do
    context "when content object class exists" do
      let!(:node) { create(:home_page_node) }

      it "deletes record" do
        expect { node.destroy }.to change { Node.count }.by(-1)
      end

      it "deletes associated record" do
        expect { node.destroy }.to change { HomePage.count }.by(-1)
      end
    end

    context "when content object class doesn't exists" do
      let!(:node) { create(:home_page_node) }
      before do
        node.update_columns(content_type: 'NonExistingTestModel')
      end

      it "deletes record" do
        expect { node.destroy }.to change { Node.count }.by(-1)
      end
    end

    it "sets node update to current time" do
      node = create(:node)
      expect( Node ).to receive(:updated).once
      node.destroy
    end
  end

  describe "#attributes_to_not_copy" do
    it "returns array with attributes" do
      expect( subject.attributes_to_not_copy ).to match_array %w[content_id depth id item_position lft rgt slug created_at updated_at]
    end
  end

  describe "#attributes_to_copy" do
    it "returns object attributes excluding #attributes_to_not_copy" do
      node = Node.new
      allow( node ).to receive(:attributes_to_not_copy).and_return(%w[lft rgt])
      expect( node.attributes_to_copy ).to eq(Node.column_names - %w[lft rgt])
    end
  end

  describe "#reasign_slug" do
    it "updates slug" do
      node = create(:node)
      old_slug = node.slug
      node.name = 'woo hoo'
      expect { node.reasign_slug }.to change { node.slug }.from(old_slug).to('woo-hoo')
    end
  end

  describe "#save_under" do
    let(:node1) { create(:node) }

    it "saves node nuder node with given node_id" do
      node2 = create(:text_page_node, parent: node1)

      new_node = FactoryGirl.build(:text_page_node)
      new_node.send(:save_under, node2.id)
      expect( new_node ).to_not be_new_record
      expect( new_node.parent ).to eq node2
    end

    it "maintains node name, updates slug and then saves record" do
      new_node = FactoryGirl.build(:text_page_node)
      expect( new_node ).to receive(:maintain_name).ordered.and_call_original
      expect( new_node ).to receive(:reasign_slug).ordered.and_call_original
      expect( new_node ).to receive(:save!).ordered.and_call_original
      new_node.save_under(node1.id)
    end

    context "when #validate_root_locale_uniqueness? returns true" do
      it "sets locale to nil" do
        new_node = FactoryGirl.build(:node)
        allow(new_node).to receive(:validate_root_locale_uniqueness?).and_return(true)
        new_node.locale = 'xx'
        expect { new_node.save_under(nil) }.to change { new_node.locale }.from('xx').to(nil)
      end
    end

    context "when #validate_root_locale_uniqueness? returns false" do
      it "doesn't set locale to nil" do
        new_node = FactoryGirl.build(:node)
        allow(new_node).to receive(:validate_root_locale_uniqueness?).and_return(false)
        new_node.locale = 'xx'
        expect { new_node.save_under(nil) }.to_not change { new_node.locale }.from('xx')
      end
    end

  end


  describe "#duplicate_content" do

    context "when #content_id is blank" do
      let(:node) { create(:node) }

      it "returns nil" do
        expect( node.duplicate_content ).to be_nil
      end
    end

    context "when #content_id is not blank" do
      let(:node) { create(:home_page_node) }

      it "returns saved duplicated content" do
        content = double('new content')
        expect( content ).to receive(:save!)
        expect( node ).to receive_message_chain(:content, :dup).and_return(content)
        expect( node.duplicate_content ).to eq content
      end

      it "doesn't return same as original content" do
        result = node.duplicate_content
        expect( result ).to be_an_instance_of HomePage
        expect( result.id ).to_not eq node.content_id
      end
    end
  end

  describe "#copy_attributes_from" do
    let(:source_node) { create(:node, active: false) }

    it "copies #attributes_to_copy attributes" do

      allow( source_node ).to receive(:attributes_to_copy).and_return(['name'])

      expect( source_node ).to receive(:name).and_call_original
      expect( source_node ).to_not receive(:parent_id)
      expect( source_node ).to_not receive(:content_type)
      expect( source_node ).to_not receive(:active)

      new_node = Node.new

      new_node.copy_attributes_from source_node

      expect( new_node.parent_id ).to be_nil
      expect( new_node.content_type ).to be_nil
      expect( new_node.active ).to be_truthy
    end
  end

  describe "#duplicate_under!" do
    let!(:source_node) { create(:node, locale: "lv") }
    let!(:target_node) { create(:node, locale: "en") }

    before do
      allow_any_instance_of(Releaf::Content::Node::RootValidator).to receive(:validate)
    end

    it "creates duplicated node under target node" do
      new_node = Node.new
      duplicated_content = double('content', id: 1234)
      expect( Node ).to receive(:new).ordered.and_return(new_node)
      expect( new_node ).to receive(:copy_attributes_from).with(source_node).ordered.and_call_original
      expect( source_node ).to receive(:duplicate_content).ordered.and_return(duplicated_content)
      expect( new_node ).to receive(:content_id=).with(1234).ordered
      expect( new_node ).to receive(:save_under).with(target_node.id).ordered.and_call_original
      source_node.duplicate_under!(target_node.id)
    end

    it "doesn't update settings timestamp" do
      expect( Node ).to_not receive(:updated)
      source_node.duplicate_under!(target_node.id)
    end
  end

  describe "#copy", create_nodes: true do
    before create_nodes: true do
      @home_page_node = create(:home_page_node, locale: "lv")
      @home_page_node_2 = create(:home_page_node, locale: "en")
      @text_page_node_3 = create(:text_page_node, parent_id: @home_page_node_2.id)
      @text_page_node_4 = create(:text_page_node, parent_id: @text_page_node_3.id)
      @text_page_node_5 = create(:text_page_node, parent_id: @text_page_node_4.id)

      # it is important to reload nodes, otherwise associations will return empty set
      @home_page_node.reload
      @home_page_node_2.reload
      @text_page_node_3.reload
      @text_page_node_4.reload
    end

    context "when one of children becomes invalid" do
      before do
        @text_page_node_4.name = nil
        @text_page_node_4.save(validate: false)
      end

      it "raises ActiveRecord::RecordInvalid" do
        expect { @text_page_node_3.copy(@home_page_node.id) }.to raise_error ActiveRecord::RecordInvalid
      end

      it "raises error on node being copied" do
        begin
          @text_page_node_3.copy(@home_page_node.id)
        rescue ActiveRecord::RecordInvalid => e
          expect( e.record ).to eq @text_page_node_3
        end
        expect(@text_page_node_3.errors.messages).to eq(base: ["descendant invalid"])
      end

      it "doesn't create any new nodes" do
        expect do
          begin
            @text_page_node_3.copy(@home_page_node.id)
          rescue ActiveRecord::RecordInvalid
          end
        end.to_not change { Node.count }
      end

      it "doesn't update settings timestamp" do
        expect( Node ).to_not receive(:updated)
        begin
          @text_page_node_3.copy(@home_page_node.id)
        rescue ActiveRecord::RecordInvalid
        end
      end

    end


    context "with corect parent_id" do
      it "creates node along with descendant nodes" do
        expect{ @text_page_node_3.copy(@home_page_node.id) }.to change{ Node.count }.by( @text_page_node_3.descendants.size + 1 )
      end

      it "correctly copies attributes" do
        allow( @text_page_node_3 ).to receive(:children).and_return([@text_page_node_4])
        allow( @text_page_node_4 ).to receive(:children).and_return([@text_page_node_5])

        @text_page_node_3.update_attribute(:active, false)
        @text_page_node_4.update_attribute(:active, false)

        allow( @text_page_node_3 ).to receive(:attributes_to_copy).and_return(["name", "parent_id", "content_type"])

        expect( @text_page_node_3 ).to receive(:duplicate_under!).and_call_original.ordered
        expect( @text_page_node_4 ).to receive(:duplicate_under!).and_call_original.ordered
        expect( @text_page_node_5 ).to receive(:duplicate_under!).and_call_original.ordered

        @text_page_node_3.copy(@home_page_node.id)

        @node_2_copy = @home_page_node.children.first
        @node_3_copy = @node_2_copy.children.first
        @node_4_copy = @node_3_copy.children.first

        # new nodes by default are active, however we stubbed
        # #attributes_to_copy of @test_node_2 to not return active attribute
        # Also we updated @test_node_2#active to be false.
        # However copy is active, because active attribute wasn't copied
        expect( @node_2_copy ).to be_active
        # for copy of @text_page_node_3 active attribute was copied however, as it
        # should have been
        expect( @node_3_copy ).to_not be_active
        expect( @node_4_copy ).to be_active

        expect( @node_2_copy.name ).to eq @text_page_node_3.name
        expect( @node_3_copy.name ).to eq @text_page_node_4.name
        expect( @node_4_copy.name ).to eq @text_page_node_5.name
      end

      it "updates settings timestamp only once" do
        expect( Node ).to receive(:updated).once.and_call_original
        @text_page_node_3.copy(@home_page_node.id)
      end

      context "when parent_id is nil" do
        it "creates new node" do
          allow_any_instance_of(Releaf::Content::Node::RootValidator).to receive(:validate)
          expect{ @text_page_node_3.copy(nil) }.to change{ Node.count }.by(3)
        end
      end

      context "when copying root nodes", create_nodes: false do
        context "when root locale uniqueness is validated" do
          it "resets locale to nil" do
            @text_page_node = create(:home_page_node, locale: 'en')
            allow_any_instance_of(Node).to receive(:validate_root_locale_uniqueness?).and_return(true)
            @text_page_node.copy(nil)
            expect( Node.last.locale ).to eq nil
          end
        end

        context "when root locale uniqueness is not validated" do
          it "doesn't reset locale to nil" do
            @text_page_node = create(:home_page_node, locale: 'en')
            allow_any_instance_of(Node).to receive(:validate_root_locale_uniqueness?).and_return(false)
            @text_page_node.copy(nil)
            expect( Node.last.locale ).to eq 'en'
          end
        end
      end
    end

    context "with nonexistent parent_id" do
      it "raises ActiveRecord::RecordInvalid" do
        expect { @text_page_node_3.copy(99991) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "with same parent_id as node.id" do
      it "raises ActiveRecord::RecordInvalid" do
        expect{ @text_page_node_3.copy(@text_page_node_3.id) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when copying to child node" do
      it "raises ActiveRecord::RecordInvalid" do
        expect{ @text_page_node_3.copy(@text_page_node_4.id) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe ".children_max_item_position" do
    before do
      @home_page_node   = create(:home_page_node, item_position: 1, locale: "lv")
      @home_page_node_2 = create(:home_page_node, item_position: 2, locale: "en")
      @text_page_node_3 = create(:text_page_node, parent_id: @home_page_node_2.id, item_position: 1)
      @text_page_node_4 = create(:text_page_node, parent_id: @home_page_node_2.id, item_position: 2)

      # it is important to reload nodes, otherwise associations will return empty set
      @home_page_node.reload
      @home_page_node_2.reload
      @text_page_node_3.reload
      @text_page_node_4.reload
    end

    context "when passing nil" do
      it "returns max item_position of root nodes" do
        expect( Node.children_max_item_position(nil) ).to eq 2
      end
    end

    context "when passing node with children" do
      it "returns max item_position of node children" do
        expect( Node.children_max_item_position(@home_page_node_2) ).to eq 2
      end
    end

    context "when passing node without children" do
      it "returns 0" do
        expect( Node.children_max_item_position(@text_page_node_4) ).to eq 0
      end
    end
  end

  describe "#move" do
    before do
      @home_page_node = create(:home_page_node, locale: "lv")
      @home_page_node_2 = create(:home_page_node, locale: "en")
      @text_page_node_3 = create(:text_page_node, parent_id: @home_page_node_2.id)
      @text_page_node_4 = create(:text_page_node, parent_id: @text_page_node_3.id)

      # it is important to reload nodes, otherwise associations will return empty set
      @home_page_node.reload
      @home_page_node_2.reload
      @text_page_node_3.reload
      @text_page_node_4.reload
    end

    context "when one of children becomes invalid" do
      before do
        @text_page_node_4.name = nil
        @text_page_node_4.save(validate: false)
      end

      it "raises ActiveRecord::RecordInvalid" do
        expect { @text_page_node_3.move(@home_page_node.id) }.to raise_error ActiveRecord::RecordInvalid
      end

      it "raises error on node being moved, even tought descendant has error" do
        begin
          @text_page_node_3.move(@home_page_node.id)
        rescue ActiveRecord::RecordInvalid => e
          expect( e.record ).to eq @text_page_node_3
        end

        expect(@text_page_node_3.errors.messages).to eq(name: [], base: ["descendant invalid"])
      end
    end

    context "when moving existing node to other nodes child's position" do
      it "changes parent_id" do
        expect{ @text_page_node_3.move(@home_page_node.id) }.to change{ Node.find(@text_page_node_3.id).parent_id }.from(@home_page_node_2.id).to(@home_page_node.id)
      end
    end

    context "when moving to self child's position" do
      it "raises ActiveRecord::RecordInvalid" do
        expect{ @text_page_node_3.move(@text_page_node_3.id) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when passing nil as target node" do
      it "updates parent_id" do
        allow_any_instance_of(Releaf::Content::Node::RootValidator).to receive(:validate)
        @home_page_node.destroy
        expect{ @text_page_node_3.move(nil) }.to change { Node.find(@text_page_node_3.id).parent_id }.to(nil)
      end
    end

    context "when passing nonexistent target node's id" do
      it "raises ActiveRecord::RecordInvalid" do
        expect{ @text_page_node_3.move(998123) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

  end

  describe "#maintain_name" do
    let(:root) { create(:home_page_node) }
    let(:node) { create(:text_page_node, parent_id: root.id, name:  "Test node") }
    let(:sibling) { create(:text_page_node, parent_id: root.id, name:  "Test node(1)") }

    context "when node don't have sibling/s with same name" do
      it "does not changes node's name" do
        new_node = Node.new(name:  "another name", parent_id: root.id)
        expect{ new_node.maintain_name }.to_not change{new_node.name}
      end
    end

    context "when node have sibling/s with same name" do
      it "changes node's name" do
        new_node = Node.new(name:  node.name, parent_id: root.id)
        expect{ new_node.maintain_name }.to change{new_node.name}.from(node.name).to("#{node.name}(1)")
      end

      it "increments node's name number" do
        sibling
        new_node = Node.new(name:  node.name, parent_id: root.id)
        expect{ new_node.maintain_name }.to change{new_node.name}.from(node.name).to("#{node.name}(2)")
      end
    end
  end

  describe ".updated_at" do
    it "returns last node update time" do
      expect( Releaf::Settings ).to receive(:[]).with('releaf.content.nodes.updated_at').and_return('test')
      expect( Node.updated_at ).to eq 'test'
    end
  end

  describe ".updated" do
    it "returns last node update time" do
      allow(Time).to receive(:now).and_return("asd")
      expect( Releaf::Settings ).to receive(:[]=).with('releaf.content.nodes.updated_at', "asd")
      Node.updated
    end
  end

  describe "#available?" do
    let(:root) { create(:home_page_node, active: true) }
    let(:node_ancestor) { create(:text_page_node, parent_id: root.id, active: true) }
    let(:node) { create(:text_page_node, parent_id: node_ancestor.id, active: true) }

    context "when object and all its ancestors are active" do
      it "returns true" do
        expect( node ).to be_available
      end
    end

    context "when object itself is not active" do
      it "returns false" do
        node.update_attribute(:active, false)
        expect( node ).to_not be_available
      end
    end

    context "when any of object ancestors are not active" do
      it "returns false" do
        node_ancestor.update_attribute(:active, false)
        expect( node ).to_not be_available
      end
    end
  end

  describe ".valid_node_content_classes" do
    it "returns array of constantized .valid_node_content_class_names" do
      expect( Node ).to receive(:valid_node_content_class_names).with(42).and_return(['TextPage', 'HomePagesController'])
      expect( Node.valid_node_content_classes(42) ).to eq [TextPage, HomePagesController]
    end
  end

  describe ".valid_node_content_class_names" do
    it "returns class names for Node#content_type that can be used to create valid node" do
      expect( ActsAsNode ).to receive(:classes).and_return(%w[BadNode GoodNode])

      node_1 = double('BadNode')
      allow(node_1).to receive(:valid?)
      node_1_errors = double("Node 1 Errors object")
      expect( node_1_errors ).to receive(:[]).with(:content_type).and_return(['some error'])
      allow(node_1).to receive(:errors).and_return(node_1_errors)

      node_2 = double('GoodNode')
      allow(node_2).to receive(:valid?)
      node_2_errors = double("Node 2 Errors object")
      expect( node_2_errors ).to receive(:[]).with(:content_type).and_return(nil)
      allow(node_2).to receive(:errors).and_return(node_2_errors)

      expect( Node ).to receive(:new).with(hash_including(parent_id: 52, content_type: 'BadNode')).and_return(node_1)
      expect( Node ).to receive(:new).with(hash_including(parent_id: 52, content_type: 'GoodNode')).and_return(node_2)

      expect( Node.valid_node_content_class_names(52) ).to eq %w[GoodNode]
    end

  end

  describe "#locale_selection_enabled?" do
    it "returns false" do
      expect( plain_subject.locale_selection_enabled? ).to be false
    end
  end

  describe "#build_content" do
    it "builds new content and assigns to #content" do
      subject.content_type = 'TextPage'
      params = {text_html: 'test'}
      expect( TextPage ).to receive(:new).with(params).and_call_original
      subject.build_content(params)
      expect( subject.content ).to be_an_instance_of TextPage
      expect( subject.content.text_html ).to eq 'test'
    end
  end

  describe "#validate_root_locale_uniqueness?" do
    before do
      allow( subject ).to receive(:root?).and_return(true)
      allow( subject ).to receive(:locale_selection_enabled?).and_return(true)
    end

    context "when #locale_selection_enabled? and #root? both are true" do
      it "returns true" do
        expect( subject.send(:validate_root_locale_uniqueness?) ).to be_truthy
      end
    end

    context "when #locale_selection_enabled? is false" do
      it "returns false" do
        allow( subject ).to receive(:locale_selection_enabled?).and_return(false)
        expect( subject.send(:validate_root_locale_uniqueness?) ).to be_falsy
      end
    end

    context "when #root? is false" do
      it "returns false" do
        allow( subject ).to receive(:root?).and_return(false)
        expect( subject.send(:validate_root_locale_uniqueness?) ).to be_falsy
      end
    end
  end

  describe "#validate_parent_node_is_not_self" do
    let(:node1) { create(:node, locale: "lv") }

    it "is called during validations" do
      expect( subject ).to receive(:validate_parent_node_is_not_self)
      subject.valid?
    end

    context "when #parent_id matches #id" do
      it "adds error on #parent_id" do
        node1.parent_id = node1.id
        node1.send(:validate_parent_node_is_not_self)
        expect( node1.errors[:parent_id] ).to include "can't be parent to itself"
      end
    end

    context "when parent is nil" do
      it "does nothing" do
        node1.parent_id = nil
        node1.send(:validate_parent_node_is_not_self)
        expect( node1.errors[:parent_id] ).to be_blank
      end
    end

    context "#id matches #parent_id" do
      it "does nothing" do
        node2 = create(:node, locale: "en")
        node1.parent_id = node2.id
        node1.send(:validate_parent_is_not_descendant)
        expect( node1.errors[:parent_id] ).to be_blank
      end
    end


  end

  describe "#validate_parent_is_not_descendant" do
    before with_tree: true do
      @node1 = create(:home_page_node, locale: "en")
      @node2 = create(:text_page_node, parent: @node1)
      @node3 = create(:text_page_node, parent: @node2)
      @node4 = create(:home_page_node, locale: "lv")

      @node1.reload
      @node2.reload
      @node3.reload
    end

    it "is called during validations" do
      expect( subject ).to receive(:validate_parent_is_not_descendant)
      subject.valid?
    end

    context "when #parent_id matches #id of one of descadents", with_tree: true do
      it "adds error on #parent_id" do
        @node1.parent_id = @node3.id
        @node1.send(:validate_parent_is_not_descendant)
        expect( @node1.errors[:parent_id] ).to include "descendant can't be parent"
      end
    end

    context "when parent is nil", with_tree: true do
      it "does nothing" do
        @node1.parent_id = nil
        @node1.send(:validate_parent_is_not_descendant)
        expect( @node1.errors[:parent_id] ).to be_blank
      end
    end

    context "when there are no descadents with #id is #self#parent_id", with_tree: true do
      it "does nothing" do
        @node1.parent_id = @node4.id
        @node1.send(:validate_parent_is_not_descendant)
        expect( @node1.errors[:parent_id] ).to be_blank
      end
    end
  end

  describe "#add_error_and_raise" do
    it "raises error" do
      expect { subject.add_error_and_raise('test error') }.to raise_error(ActiveRecord::RecordInvalid)
    end

    it "adds record on base and raise ActiveRecord::RecordInvalid" do
      begin
        subject.add_error_and_raise('test error')
      rescue ActiveRecord::RecordInvalid => e
        expect( e.record.errors[:base] ).to include 'test error'
      end
    end
  end

  describe "#prevent_auto_update_settings_timestamp" do
    it "sets #prevent_auto_update_settings_timestamp? to true within block" do
      expect do
        subject.prevent_auto_update_settings_timestamp do
          expect( subject.send(:prevent_auto_update_settings_timestamp?) ).to be_truthy
        end
      end.to_not change { subject.send(:prevent_auto_update_settings_timestamp?) }.from(false)
    end
  end

  describe "#update_settings_timestamp" do
    it "calls .updated" do
      expect( Node ).to receive(:updated).and_call_original
      subject.send(:update_settings_timestamp)
    end

    context "when #prevent_auto_update_settings_timestamp? is false" do
      it "is called after save" do
        node = FactoryGirl.build(:node)
        allow( node ).to receive(:prevent_auto_update_settings_timestamp?).and_return(false)
        expect( node ).to receive(:update_settings_timestamp).and_call_original
        node.save!
      end
    end

    context "when #prevent_auto_update_settings_timestamp? is true" do
      it "is not called after save" do
        node = FactoryGirl.build(:node)
        allow( node ).to receive(:prevent_auto_update_settings_timestamp?).and_return(true)
        expect( node ).to_not receive(:update_settings_timestamp)
        node.save!
      end
    end
  end

  describe "#path" do
    it "returns relative path of node" do
      node = described_class.new(slug: 'foo')
      node2 = described_class.new(slug: 'bar', parent: node)
      expect( node.path ).to eq '/foo'
      expect( node2.path ).to eq '/foo/bar'
    end
  end
end
