require "rails_helper"

describe Releaf::Content::Node::SaveUnderParent do
  class DummyNodeServiceIncluder
    include Releaf::Content::Node::Service
  end

  let(:root_node){ create(:node, locale: "lv") }
  let(:node){ build(:text_page_node) }
  subject{ described_class.new(node: node, parent_id: root_node.id) }

  describe "#call" do
    it "saves node nuder node with given node_id" do
      node2 = create(:text_page_node, parent: root_node)

      subject.parent_id = node2.id
      subject.call
      expect( node ).to_not be_new_record
      expect( node.parent ).to eq node2
    end

    it "maintains node name and slug, then saves record" do
      expect( node ).to receive(:maintain_name).ordered.and_call_original
      expect( node ).to receive(:maintain_slug).ordered.and_call_original
      expect( node ).to receive(:save!).ordered.and_call_original
      subject.call
    end

    context "when #validate_root_locale_uniqueness? returns true" do
      let(:node){ root_node }

      it "sets locale to nil" do
        allow(node).to receive(:validate_root_locale_uniqueness?).and_return(true)
        subject.parent_id = nil
        expect { subject.call }.to change{ node.locale }.from("lv").to(nil)
      end
    end

    context "when #validate_root_locale_uniqueness? returns false" do
      let(:node){ root_node }

      it "doesn't set locale to nil" do
        allow(node).to receive(:validate_root_locale_uniqueness?).and_return(false)
        subject.parent_id = nil
        expect { subject.call }.to_not change{ node.locale }
      end
    end
  end
end
