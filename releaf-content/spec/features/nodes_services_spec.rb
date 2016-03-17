require 'rails_helper'
describe "Nodes services (copy, move)" do

  describe "Moving" do
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

  describe "Copying", create_nodes: true do
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
end
