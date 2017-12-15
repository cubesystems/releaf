require "rails_helper"

describe Releaf::Content::BuildRouteObjects do
  let(:home_page_node) { create(:home_page_node, id: 23, locale: "lv", slug: "llvv") }
  let(:node) { create(:text_page_node, id: 27, parent: home_page_node, slug: "some-text") }
  let(:controller) { Releaf::Content::Route.default_controller( node.class ) }
  let(:subject) { described_class.new(node_class: node.class, node_content_class: TextPage, default_controller: controller) }

  describe "#call" do
    it "returns an array" do
      expect(subject.call).to be_a Array
    end

    it "returns an array of Node::Route objects" do
      result = subject.call
      expect(result.count).to eq(1)
      expect(result.first.class).to eq(Releaf::Content::Route)
    end
  end

  describe "#nodes" do
    it "returns all nodes" do
      expect(subject.nodes).to match_array([home_page_node, node])
    end
  end

  describe "#content_nodes" do
    it "returns nodes with a specified content class" do
      expect(subject.content_nodes).to eq([node])
    end
  end

  describe "#build_route_object" do
    let(:route) { subject.build_route_object(node) }

    context "when node is not available" do
      it "does not include it in return" do
        allow_any_instance_of(Node).to receive(:available?).and_return(false)
        expect(route).to be_nil
      end
    end

    it "returns a route instance" do
      expect(route).to be_a Releaf::Content::Route
    end

    it "assigns node_class from given node" do
      expect(route.node_class).to be Node
    end

    it "assigns node_id from given node" do
      expect(route.node_id).to eq "27"
    end

    it "assigns path from given node" do
      expect(route.path).to eq "/llvv/some-text"
    end

    it "assigns locale from given node" do
      expect(route.locale).to eq "lv"
    end

    it "assigns default_controller from given argument" do
      expect(route.default_controller).to be controller
    end

    it "assigns site from content routing configuration" do
      allow( Releaf::Content).to receive(:routing).and_return('Node' => {site: 'some_site'})
      expect(route.site).to eq 'some_site'
    end
  end
end
