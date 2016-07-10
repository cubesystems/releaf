require "rails_helper"

describe Releaf::Content::Node::Copy do
  class DummyNodeServiceIncluder
    include Releaf::Content::Node::Service
  end

  let(:node){ Node.new }
  subject{ described_class.new(node: node, parent_id: 12) }

  describe "#duplicate_content" do
    let(:node) { create(:node) }

    context "when content_id is blank" do
      it "returns nil" do
        expect( subject.duplicate_content ).to be nil
      end
    end

    context "when content_id is not blank" do
      let(:node) { create(:home_page_node) }

      it "returns saved duplicated content" do
        content = HomePage.new
        expect( content ).to receive(:save!)
        expect( node.content.class ).to receive(:new).and_return(content)
        expect( subject.duplicate_content ).to eq content
      end

      it "reassigns dragonfly accessors" do
        content = HomePage.new
        expect( content ).to receive(:save!)
        allow( node.content.class ).to receive(:new).and_return(content)
        expect( subject ).to receive(:duplicate_content_dragonfly_attributes).with(content)
        expect( subject.duplicate_content ).to eq content
      end

      it "doesn't return same as original content" do
        result = subject.duplicate_content
        expect( result ).to be_an_instance_of HomePage
        expect( result.id ).to_not eq node.content_id
      end
    end
  end

  describe "#cloned_content_attributes" do
    it "returns attributes without id and dragonfly attributes" do
      node.content = HomePage.new(id: 42, banner_uid: "re", intro_text_html: "some text")

      expect(subject.cloned_content_attributes).to have_key("intro_text_html")
      expect(subject.cloned_content_attributes).not_to include(:id, :banner_uid)
    end
  end

  describe "#duplicate_content_dragonfly_attributes" do
    context "when dragonfly file is present" do
      it "reassigns dragonfly accessors to given content instance from node content" do
        old_content = HomePage.create(banner: File.new("releaf-core/spec/fixtures/cs.png"))
        new_content = HomePage.new()
        node.content = old_content

        expect(new_content).to receive(:banner=).with(old_content.banner)
        expect(new_content).to receive(:banner_uid=).with(nil)
        subject.duplicate_content_dragonfly_attributes(new_content)
      end
    end

    context "when dragonfly file is not present" do
      it "doesn't reassigns dragonfly accessors to given content instance from node content" do
        old_content = HomePage.new(banner_uid: "yy")
        new_content = HomePage.new()
        node.content = old_content

        expect(new_content).to receive(:banner=).with(nil)
        expect(new_content).to receive(:banner_uid=).with(nil)
        subject.duplicate_content_dragonfly_attributes(new_content)
      end
    end
  end

  describe "#content_dragonfly_attributes" do
    it "returns array of node content object dragonfly attributes" do
      node.content = HomePage.new
      expect(subject.content_dragonfly_attributes).to eq(["banner_uid"])
    end
  end

  describe "#duplicate_under" do
    let!(:source_node) { create(:node, locale: "lv") }
    let!(:target_node) { create(:node, locale: "en") }

    before do
      allow_any_instance_of(Releaf::Content::Node::RootValidator).to receive(:validate)
      subject.node = source_node
      subject.parent_id = target_node.id
    end

    it "creates duplicated node under target node" do
      new_node = Node.new
      duplicated_content = double('content', id: 1234)
      expect( Node ).to receive(:new).ordered.and_return(new_node)
      expect( new_node ).to receive(:assign_attributes_from).with(source_node).ordered.and_call_original
      expect( subject ).to receive(:duplicate_content).ordered.and_return(duplicated_content)
      expect( new_node ).to receive(:content_id=).with(1234).ordered
      expect( Releaf::Content::Node::SaveUnderParent ).to receive(:call).with(node: new_node, parent_id: target_node.id)
        .ordered.and_call_original
      expect(subject.duplicate_under).to eq(new_node)
    end

    it "doesn't update settings timestamp" do
      expect( Node ).to_not receive(:updated)
      subject.duplicate_under
    end
  end
end
