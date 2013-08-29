# encoding: UTF-8

require "spec_helper"

describe Releaf::Node::Route do
  let(:node_route) { FactoryGirl.build(:node_route, node_id: 12, locale: "en", path: "/en") }

  describe ".for" do
    it "return array" do
      expect(Releaf::Node::Route.for(Text).class).to eq(Array)
    end

    context "when no releaf_nodes table defined" do
      it "return empty array" do
        Releaf::Node::Route.stub(:nodes_available?).and_return(false)
        expect(Releaf::Node::Route.for(Text)).to eq([])
      end
    end

    context "when releaf_nodes table defined and content nodes exists" do
      it "return array with Node::Route objects" do
        FactoryGirl.create(:text_node)
        expect(Releaf::Node::Route.for(Text).first.class).to eq(Releaf::Node::Route)
      end
    end
  end

  describe '#params' do
    it "return hash with node_id" do
      expect(node_route.params("home#index")[:node_id]).to eq(12)
    end

    it "return hash with locale" do
      expect(node_route.params("home#index")[:locale]).to eq("en")
    end

    it "return hash with path" do
      expect(node_route.params("home#index")["/en"]).to eq("home#index")
    end

    it "merge overwrite passed args" do
      expect(node_route.params("home#index", locale: "de")[:locale]).to eq("de")
    end

    context "when :as hash given" do
      context "when node have locale defined" do
        it "merge overwrite passed args" do
          expect(node_route.params("home#index", as: "home")[:as]).to eq("en_home")
        end
      end

      context "when node do not have locale defined" do
        it "merge overwrite passed args" do
          node_route.locale = nil
          expect(node_route.params("home#index", as: "home")[:as]).to eq("home")
        end
      end
    end
  end
end
