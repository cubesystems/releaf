require "spec_helper"

describe Releaf::Node::Route do
  let(:node_route) { FactoryGirl.build(:node_route, node_id: 12, locale: "en", path: "/en") }

  describe ".for" do
    it "returns an array" do
      expect(Releaf::Node::Route.for(Text).class).to eq(Array)
    end

    context "when no releaf_nodes table defined" do
      it "returns an empty array" do
        Releaf::Node::Route.stub(:nodes_available?).and_return(false)
        expect(Releaf::Node::Route.for(Text)).to eq([])
      end
    end

    context "when releaf_nodes table defined and content nodes exist" do
      before do
        FactoryGirl.create(:text_node)
      end

      it "returns an array of Node::Route objects" do
        expect(Releaf::Node::Route.for(Text).first.class).to eq(Releaf::Node::Route)
      end

      context "when node is not available" do
        it "does not include it in return" do
          Releaf::Node.any_instance.stub(:available?).and_return(false)
          expect(Releaf::Node::Route.for(Text)).to eq([])
        end
      end
    end
  end

  describe '#params' do

    it "returns a hash with node_id" do
      expect(node_route.params("home#index")[:node_id]).to eq('12')
    end

    it "returns a hash with locale" do
      expect(node_route.params("home#index")[:locale]).to eq("en")
    end

    it "returns a hash with path" do
      expect(node_route.params("home#index")["/en"]).to eq("home#index")
    end

    it "merges passed args into the returned hash" do
      expect(node_route.params("home#index", locale: "de")[:locale]).to eq("de")
    end

    context "when hash given as first argument" do

      it "uses it for args" do
        expect(node_route.params('en/search' => 'home#search')['en/search']).to eq('home#search')
      end

      it "does not set default path in hash" do
        expect(node_route.params('en/search' => 'home#search')).to_not have_key('en/')
      end

    end

    context "when :as given in args" do

      context "when node has a locale" do
        it "prepends locale to :as" do
          expect(node_route.params("home#index", as: "home")[:as]).to eq("en_home")
        end
      end

      context "when node does not have a locale" do
        it "uses :as as passed" do
          node_route.locale = nil
          expect(node_route.params("home#index", as: "home")[:as]).to eq("home")
        end
      end
    end
  end
end
