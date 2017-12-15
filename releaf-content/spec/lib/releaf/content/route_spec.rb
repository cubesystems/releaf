require "rails_helper"

describe Releaf::Content::Route do
  let(:node_route) { FactoryGirl.build(:node_route, node_class: Node, node_id: 12, locale: "en", path: "/en") }


  describe ".default_controller" do
    context "when given node class inherits `ActionController::Base`" do
      it "returns undercored, stripped down controller class" do
        expect(described_class.default_controller(HomePagesController)).to eq("home_pages")
      end
    end

    context "when given node class does not inherit `ActionController::Base`" do
      it "returns pluralized, underscorized class" do
        expect(described_class.default_controller(TextPage)).to eq("text_pages")
      end
    end
  end


  describe '#params' do
    let(:options_argument) { { foo: :bar } }

    it "returns params for router method" do
      expect(node_route.params("home#index")).to eq ['/en', {to: "home#index", node_class: "Node", node_id: "12", locale: "en", as: nil }]
    end

    it "uses #path_for to calculate path" do
      allow(node_route).to receive(:path_for).with("home#index", options_argument).and_return( "foo_path" )
      expect(node_route.params("home#index", options_argument)[0]).to eq "foo_path"
    end

    it "uses #options_for to calculate options" do
      allow(node_route).to receive(:options_for).with("home#index", options_argument).and_return( some: :options )
      expect(node_route.params("home#index", options_argument)[1]).to eq( some: :options )
    end

    it "converts method_or_path argument to string" do
      expect(node_route).to receive(:path_for).with("foo", options_argument)
      expect(node_route).to receive(:options_for).with("foo", options_argument)
      node_route.params(:foo, options_argument)
    end

    it "does not require options argument" do
      expect(node_route).to receive(:path_for).with("home#index", {})
      expect(node_route).to receive(:options_for).with("home#index", {})
      node_route.params("home#index")
    end

  end

  describe "#path_for" do

    it "returns route path" do
      expect( node_route.path_for( "foo", {} ) ).to eq "/en"
    end

    context "when options contain a :to key" do
      it "returns route path combined with given method_or_path" do
        expect( node_route.path_for( "foo", { to: "bar" } ) ).to eq "/en/foo"
      end
    end

    context "when first argument contains a controller#action or #action string" do
      it "returns the route path" do
        expect( node_route.path_for( "home#index", { to: "bar" } ) ).to eq "/en"
      end
    end

  end

  describe "#options_for" do

    it "returns route options hash" do
      expect( node_route.options_for( "home#index", {} ) ).to be_a Hash
    end

    it "sets :node_class to route node class name string" do
      expect( node_route.options_for( "home#index", {} ) ).to include( node_class: "Node" )
    end

    it "sets :node_id to route node id string" do
      expect( node_route.options_for( "home#index", {} ) ).to include( node_id: "12" )
    end

    it "sets :locale to route locale" do
      expect( node_route.options_for( "home#index", {} ) ).to include( locale: "en" )
    end

    it "sets :to to the result of #controller_and_action_for" do
      allow(node_route).to receive(:controller_and_action_for).with( "home#index", foo: :bar).and_return("ok")
      expect( node_route.options_for( "home#index", foo: :bar ) ).to include( to: "ok" )
    end

    it "sets :as to the result of #name by passing all other calculated options" do
      expected_name_options = {
        foo: :bar,
        to: "home#index",
        node_class: "Node",
        node_id: "12",
        locale: "en"
      }

      allow(node_route).to receive(:name).with( expected_name_options ).and_return("ok")
      expect( node_route.options_for( "home#index", foo: :bar ) ).to include( as: "ok" )
    end

    it "preserves unrecognized option keys" do
      expect( node_route.options_for( "home#index", foo: :bar ) ).to include( foo: :bar )
    end

    it "uses calculated keys in case conflicting option keys given" do
      in_options = { to: "invalid", node_class: "invalid", node_id: "invalid", locale: "invalid" }

      expect( node_route.options_for( "home#index", in_options ) ).to include({
        to: "home#index",
        node_class: "Node",
        node_id: "12",
        locale: "en"
      })
    end

    context "when node route has site" do

      it "sets :site to route site" do
        node_route.site = "ok"
        expect( node_route.options_for( "home#index", {} ) ).to include( site: "ok" )
      end

      it "overrides site given in options" do
        node_route.site = "ok"
        expect( node_route.options_for( "home#index", { site: "foo" } ) ).to include( site: "ok" )
      end

    end

    context "when node route does not have site" do

      it "does not set :site" do
        expect( node_route.options_for( "home#index", {} ) ).to_not include( :site )
      end

      it "allows site from options" do
        expect( node_route.options_for( "home#index", { site: "ok" } ) ).to include( site: "ok" )
      end

    end


  end

  describe "#name" do

    context "when route options contain :as option" do

      context "when neither :site nor :locale are set or are blank in route options" do
        it "returns the value intact" do
          expect(node_route.name( { as: "foo" } )).to eq "foo"
          expect(node_route.name( { as: "foo", site: nil, locale: nil } )).to eq "foo"
        end
      end

      context "when :site is set in route options" do
        it "returns the value with site prepended" do
          expect(node_route.name( { as: "foo", site: "sss" } )).to eq "sss_foo"
        end
      end

      context "when :locale is set in route options" do
        it "returns the value with locale prepended" do
          expect(node_route.name( { as: "foo", locale: "lll" } )).to eq "lll_foo"
        end
      end

      context "when both :site and :locale are set in route options" do
        it "returns the value with site and locale prepended" do
          expect(node_route.name( { as: "foo", site: "sss", locale: "lll" } )).to eq "sss_lll_foo"
        end
      end

    end

    context "when route options do not contain :as option" do
      it "returns nil" do
        expect(node_route.name( {} )).to be_nil
      end
    end

  end

  describe ".for" do
    before do
      create(:home_page_node)
    end

    it "returns an array" do
      expect(described_class.for(Node, HomePage, 'foo')).to be_a Array
    end

    context "when database doesn't exists" do
      it "returns an empty array" do
        allow(Node).to receive(:where).and_raise(ActiveRecord::NoDatabaseError.new("xxx"))
        expect(described_class.for(Node, HomePage, 'foo')).to eq([])
      end
    end

    context "when node table doesn't exist" do
      it "returns an empty array" do
        allow(Node).to receive(:where).and_raise(ActiveRecord::StatementInvalid.new("xxx"))
        expect(described_class.for(Node, HomePage, 'foo')).to eq([])
      end
    end

    context "when node table exists" do
      it "returns an array of Node::Route objects processed by Releaf::Content::BuildRouteObjects" do
        expect(Releaf::Content::BuildRouteObjects).to receive(:call).with(node_class: Node, node_content_class: HomePage, default_controller: 'foo').and_call_original
        result = described_class.for(Node, HomePage, 'foo')
        expect(result.count).to eq(1)
        expect(result.first.class).to eq(described_class)
      end

      it "accepts node_class as string also" do
        result = described_class.for('Node', HomePage, 'foo')
        expect(result.count).to eq(1)
      end
    end
  end
end
