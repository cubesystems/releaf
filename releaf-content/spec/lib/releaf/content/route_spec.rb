require "rails_helper"

describe Releaf::Content::Route do
  let(:node_route) { FactoryGirl.build(:node_route, node_id: 12, locale: "en", path: "/en") }

  describe ".node_class" do
    it "returns ::Node" do
      expect( described_class.node_class ).to eq ::Node
    end
  end

  describe ".for" do
    before do
      create(:home_page_node)
    end

    it "returns an array" do
      expect(described_class.for(HomePage).class).to eq(Array)
    end

    context "when databse doesn't exists" do
      it "returns an empty array" do
        allow(described_class.node_class).to receive(:where).and_raise(ActiveRecord::NoDatabaseError.new("xxx"))
        expect(described_class.for(HomePage)).to eq([])
      end
    end

    context "when releaf_nodes table doesn't exists" do
      it "returns an empty array" do
        allow(described_class.node_class).to receive(:where).and_raise(ActiveRecord::StatementInvalid.new("xxx"))
        expect(described_class.for(HomePage)).to eq([])
      end
    end

    context "when releaf_nodes table exists" do
      it "returns an array of Node::Route objects" do
        result = described_class.for(HomePage)
        expect(result.count).to eq(1)
        expect(result.first.class).to eq(described_class)
      end

      context "when node is not available" do
        it "does not include it in return" do
          allow_any_instance_of(Node).to receive(:available?).and_return(false)
          expect(described_class.for(HomePage)).to eq([])
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
