require "spec_helper"

describe Node do

  let(:node) { Node.new }

  it { is_expected.to accept_nested_attributes_for(:content) }
  it { is_expected.to belong_to(:content) }

  it "includes Releaf::Content::Node module" do
    expect( Node.included_modules ).to include Releaf::Content::Node
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_presence_of(:content_type) }
    it { is_expected.to validate_uniqueness_of(:slug).scoped_to(:parent_id) }
    it { is_expected.to ensure_length_of(:name).is_at_most(255) }
    it { is_expected.to ensure_length_of(:slug).is_at_most(255) }
  end

  describe "after save" do
    it "sets node update to current time" do
      Releaf::Settings['releaf.content.nodes.updated_at'] = Time.now
      time_now = Time.parse("2009-02-23 21:00:00 UTC")
      allow(Time).to receive(:now).and_return(time_now)

      expect{ FactoryGirl.create(:node) }.to change{ Releaf::Settings['releaf.content.nodes.updated_at'] }.to(time_now)
    end
  end

  describe "#own_fields_to_display" do
    it "returns blank array" do
      expect( node.own_fields_to_display ).to eq []
    end
  end

  describe "#content_fields_to_display" do
    context "when #content_type is name of non ActiveRecord class" do
      it "returns nil" do
        node.content_type = 'TrueClass'
        expect( node.content_fields_to_display('edit') ).to be_nil
      end
    end

    context "when #content_type is name of ActionController class" do
      it "returns nil" do
        node.content_type = 'TextsController'
        expect( node.content_fields_to_display('edit') ).to be_nil
      end
    end

    context "when #content_type is name of ActiveRecord model that acts as node" do
      it "display all but #id, #updated_at and #created_at fields" do
        node.content_type = 'Book'
        expect( node.content_fields_to_display('edit') ).to match_array(Book.column_names - %w[id created_at updated_at])
      end
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
      expect(node.to_s).to eq(node.name)
    end
  end

  describe "#locale" do
    before do
      root = FactoryGirl.create(:node, locale: "lv")
      parent = FactoryGirl.create(:node, locale: nil, parent_id: root.id)
      @child1 = FactoryGirl.create(:node, locale: nil, parent_id: parent.id)
      @child2 = FactoryGirl.create(:node, locale: nil, parent_id: parent.id, locale: "en")
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
    def stub_content_class &block
      allow_any_instance_of(Node).to receive(:content_class)
      yield
      allow_any_instance_of(Node).to receive(:content_class).and_call_original
    end

    context "when content object class exists" do
      let(:text) { FactoryGirl.create(:text) }
      let!(:node) { FactoryGirl.create(:node, content: text) }

      it "deletes record" do
        expect { node.destroy }.to change { Node.count }.by(-1)
      end

      it "deletes associated record" do
        expect { node.destroy }.to change { Text.count }.by(-1)
      end
    end

    context "when content object class doesn't exists" do
      it "deletes record" do
        stub_content_class do
          @node = FactoryGirl.create(:node, content_type: 'NonExistingTestModel', content_id: 1)
        end
        expect { @node.destroy }.to change { Node.count }.by(-1)
      end

      it "retries to delete record only once" do
        stub_content_class do
          @node = FactoryGirl.create(:node, content_type: 'NonExistingTestModel', content_id: 1)
        end
        allow(@node).to receive(:content_type=)
        allow(@node).to receive(:content_id=)

        expect { @node.destroy }.to raise_error NameError
        expect( Node.count ).to eq 1
      end
    end

    it "sets node update to current time" do
      node = FactoryGirl.create(:node)
      time_now = Time.parse("2009-02-23 21:00:00 UTC")
      allow(Time).to receive(:now).and_return(time_now)
      expect{ node.destroy }.to change{ Releaf::Settings['releaf.content.nodes.updated_at'] }.to(time_now)
    end
  end

  describe "#attributes_to_not_copy" do
    it "returns array with attributes" do
      expect( subject.attributes_to_not_copy ).to match_array %w[content_id depth id item_position lft locale rgt slug created_at updated_at]
    end
  end

  describe "#attributes_to_copy" do
    it "returns object attributes excluding #attributes_to_not_copy" do
      node = Node.new
      allow( node ).to receive(:attributes_to_not_copy).and_return(%w[lft rgt])
      expect( node.attributes_to_copy ).to eq(Node.column_names - %w[lft rgt])
    end
  end

  describe "#copy_to_node!", create_nodes: true do
    before create_nodes: true do
      @text_node = FactoryGirl.create(:text_node)
      @text_node_2 = FactoryGirl.create(:text_node)
      @text_node_3 = FactoryGirl.create(:text_node, parent_id: @text_node_2.id)
      @text_node_4 = FactoryGirl.create(:text_node, parent_id: @text_node_3.id)
    end

    # TODO write test to verify which attributes are copied to new node

    context "when one of children becomes invalid" do
      before do
        @text_node_4.name = nil
        @text_node_4.save(:validate => false)
      end

      it "raises ActiveRecord::RecordInvalid" do
        expect { @text_node_2.copy_to_node!(@text_node.id) }.to raise_error ActiveRecord::RecordInvalid
      end

      it "raises error on node being moved, even tought descendant has error" do
        begin
        rescue ActiveRecord::RecordInvalid => e
          expect( e.record ).to eq @text_node_2
        end
      end
    end

    context "with corect parent_id" do
      it "creates new node" do
        expect{ @text_node_2.copy_to_node!(@text_node.id) }.to change{ Node.count }.by(3)
      end
    end

    context "when node have children" do
      it "creates multiple new nodes" do
        @text_node_2.copy_to_node!(@text_node.id)
        @text_node.reload
        expect{ @text_node.copy_to_node!(@text_node_2.id) }.to change{ Node.count }.by( @text_node.descendants.size + 1 )
      end
    end

    context "when parent_id is nil" do
      it "creates new node" do
        expect{ @text_node_3.copy_to_node!(nil) }.to change{ Node.count }.by(2)
      end
    end

    context "when copying root nodes", create_nodes: false do
      context "when root locale uniqueness is validated" do
        it "resets locale to nil" do
          @text_node = FactoryGirl.create(:text_node, locale: 'en')
          allow_any_instance_of(Node).to receive(:validate_root_locale_uniqueness?).and_return(true)
          @text_node.copy_to_node!(nil)
          expect( Node.last.locale ).to eq nil
        end
      end

      context "when root locale uniqueness is not validated" do
        it "doesn't reset locale to nil" do
          @text_node = FactoryGirl.create(:text_node, locale: 'en')
          allow_any_instance_of(Node).to receive(:validate_root_locale_uniqueness?).and_return(false)
          @text_node.copy_to_node!(nil)
          expect( Node.last.locale ).to eq 'en'
        end
      end
    end

    context "with nonexistent parent_id" do
      it "raises ActiveRecord::RecordInvalid" do
        expect { @text_node_2.copy_to_node!(99991) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "with same parent_id as node.id" do
      it "raises ActiveRecord::RecordInvalid" do
        expect{ @text_node.copy_to_node!(@text_node.id) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe ".children_max_item_position" do
    before do
      @text_node   = FactoryGirl.create(:text_node, item_position: 1)
      @text_node_2 = FactoryGirl.create(:text_node, item_position: 2)
      @text_node_3 = FactoryGirl.create(:text_node, parent_id: @text_node_2.id, item_position: 1)
      @text_node_4 = FactoryGirl.create(:text_node, parent_id: @text_node_2.id, item_position: 2)
      @text_node_5 = FactoryGirl.create(:text_node, item_position: 3)
    end

    context "when passing nil" do
      it "returns max item_position of root nodes" do
        expect( Node.children_max_item_position(nil) ).to eq 3
      end
    end

    context "when passing node with children" do
      it "returns max item_position of node children" do
        expect( Node.children_max_item_position(@text_node_2) ).to eq 2
      end
    end

    context "when passing node without children" do
      it "returns 0" do
        expect( Node.children_max_item_position(@text_node_5) ).to eq 0
      end
    end
  end

  describe "#move_to_node!" do
    before do
      @text_node = FactoryGirl.create(:text_node)
      @text_node_2 = FactoryGirl.create(:text_node)
      @text_node_3 = FactoryGirl.create(:text_node, parent_id: @text_node_2.id)
      @text_node_4 = FactoryGirl.create(:text_node, parent_id: @text_node_3.id)
    end

    context "when one of children becomes invalid" do
      before do
        @text_node_4.name = nil
        @text_node_4.save(:validate => false)
      end

      it "raises ActiveRecord::RecordInvalid" do
        expect { @text_node_2.move_to_node!(@text_node.id) }.to raise_error ActiveRecord::RecordInvalid
      end

      it "raises error on node being moved, even tought descendant has error" do
        begin
        rescue ActiveRecord::RecordInvalid => e
          expect( e.record ).to eq @text_node_2
        end
      end
    end

    context "when moving existing node to other nodes child's position" do
      it "changes parent_id" do
        expect{ @text_node_3.move_to_node!(@text_node.id) }.to change{ Node.find_by_id(@text_node_3.id).parent_id }.from(@text_node_2.id).to(@text_node.id)
      end
    end

    context "when moving to self child's position" do
      it "raises ActiveRecord::RecordInvalid" do
        expect{ @text_node_3.move_to_node!(@text_node_3.id) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "when passing nil as target node" do
      it "updates parent_id" do
        expect{ @text_node_3.move_to_node!(nil) }.to change { Node.find_by_id(@text_node_3.id).parent_id }.to(nil)
      end
    end

    context "when passing nonexistent target node's id" do
      it "raises ActiveRecord::RecordInvalid" do
        expect{ @text_node_3.move_to_node!(998123) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

  end

  describe "#maintain_name" do
    let(:root) { FactoryGirl.create(:text_node) }
    let(:node) { FactoryGirl.create(:text_node, parent_id: root.id, name:  "Test node") }
    let(:sibling) { FactoryGirl.create(:text_node, parent_id: root.id, name:  "Test node(1)") }

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

  describe "#available?" do
    let(:root) { FactoryGirl.create(:text_node, active: true) }
    let(:node_ancestor) { FactoryGirl.create(:text_node, parent_id: root.id, active: true) }
    let(:node) { FactoryGirl.create(:text_node, parent_id: node_ancestor.id, active: true) }

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
      expect( Node ).to receive(:valid_node_content_class_names).with(42).and_return(['Text', 'HomeController'])
      expect( Node.valid_node_content_classes(42) ).to eq [Text, HomeController]
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

end
