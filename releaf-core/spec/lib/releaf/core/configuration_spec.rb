require "rails_helper"

describe Releaf::Core::Configuration do
  class DummyComponentA
    def self.configure_component; end
  end
  class DummyComponentB
    def self.initialize_component; end
  end
  class DummyComponentC
    def self.initialize_component; end
    def self.configure_component; end
  end

  describe "#components=" do
    before do
      allow(subject).to receive(:flatten_components).with(["x", "s"])
        .and_return([DummyComponentA, DummyComponentB, DummyComponentC])
    end

    it "assigns normalized components" do
      expect{ subject.components = ["x", "s"] }.to change{ subject.components }.to([DummyComponentA, DummyComponentB, DummyComponentC])
    end

    it "calls component configuration if available" do
      expect(DummyComponentA).to receive(:configure_component).ordered
      expect(DummyComponentC).to receive(:configure_component).ordered
      subject.components = ["x", "s"]
    end
  end

  describe "#initialize_components" do
    it "adds component configuration and calls component initializing method if available" do
      allow(subject).to receive(:components).and_return([DummyComponentA, DummyComponentB, DummyComponentC])
      expect(DummyComponentB).to receive(:initialize_component).ordered
      expect(DummyComponentC).to receive(:initialize_component).ordered
      subject.initialize_components
    end
  end

  describe "#add_configuration" do
    it "creates configuration class accessor for given configuration instance, and assigns given instance to it" do
      class Releaf::Core::Configuration::DummySampleConfiguration; end
      configuration = Releaf::Core::Configuration::DummySampleConfiguration.new

      expect(subject.respond_to?(:dummy_sample)).to be false
      subject.add_configuration(configuration)

      expect(subject.respond_to?(:dummy_sample)).to be true
      expect(subject.dummy_sample).to eq(configuration)
    end
  end

  describe "#initialize_locales" do
    before do
      subject.available_locales = [:a, :b]
      subject.available_admin_locales = [:b, :c]
      allow(::I18n).to receive(:available_locales=)
    end

    it "assigns available locales to `I18n.available_locales`" do
      expect(::I18n).to receive(:available_locales=).with([:a, :b])
      subject.initialize_locales
    end

    context "when no `available_admin_locales` defined" do
      it "overwrites it with available locales" do
        expect{ subject.initialize_locales }.to_not change{ subject.available_admin_locales }

        subject.available_admin_locales = nil
        expect{ subject.initialize_locales }.to change{ subject.available_admin_locales }.to eq([:a, :b])
      end
    end
  end

  describe "#all_locales" do
    before do
      subject.available_locales = [:a, :b]
      subject.available_admin_locales = [:b, :c]
    end

    it "merges unique locales form admin and available locales, casts it to strings and assign to `all_locales`" do
      expect( subject.all_locales ).to eq(["a", "b", "c"])
    end

    it "caches resolved locales" do
      expect(subject).to receive(:available_locales).and_call_original.once
      expect(subject).to receive(:available_admin_locales).and_call_original.once
      subject.all_locales
      subject.all_locales
    end
  end

  describe "#flatten_components" do
    it "returns recursively flattened component list" do
      class DummyComponentA; end
      class DummyComponentB
        def self.components
          ["o", "p"]
        end
      end

      allow(subject).to receive(:flatten_components).and_call_original
      allow(subject).to receive(:flatten_components).with(["o", "p"]).and_return(["x", "y"])
      expect(subject.flatten_components([DummyComponentA, DummyComponentB])).to eq([DummyComponentA, "x", "y", DummyComponentB])
    end
  end

  describe "#menu=" do
    it "normalizes menu before assigning" do
      allow(described_class).to receive(:normalize_controllers).with(["a"]).and_return(["aa"])
      expect{ subject.menu = ["a"] }.to change{ subject.menu }.to(["aa"])
    end
  end

  describe "#additional_controllers=" do
    it "normalizes additional controllers before assigning" do
      allow(described_class).to receive(:normalize_controllers).with(["b"]).and_return(["bb"])
      expect{ subject.additional_controllers = ["b"] }.to change{ subject.additional_controllers }.to(["bb"])
    end
  end

  describe "#controllers" do
    it "returns extracted controllers from menu and additional controllers attributes" do
      allow(subject).to receive(:menu).and_return(["a", "b"])
      allow(subject).to receive(:additional_controllers).and_return(["c", "d"])
      allow(subject).to receive(:extract_controllers).with(["a", "b", "c", "d"]).and_return("xxx")
      expect( subject.controllers ).to eq("xxx")
    end

    it "caches resolved controllers" do
      expect(subject).to receive(:extract_controllers).and_call_original.once
      subject.controllers
      subject.controllers
    end
  end

  describe "#available_controllers" do
    before do
      allow(subject).to receive(:controllers).and_return("c" => "d", "l" => "k")
    end

    it "returns controller names" do
      expect( subject.available_controllers ).to eq(["c", "l"])
    end

    it "caches resolved controller names" do
      expect(subject).to receive(:controllers).and_call_original.once
      subject.available_controllers
      subject.available_controllers
    end
  end

  describe "#extract_controllers" do
    it "returns recursively built hash with controllers from given array" do
      list = [{controller: "a"}, {items: [{controller: "b"}, {controller: "c"}, {xx: "x"}]}, {controller: "d"}, {asd: "xx"}]
      result = {"a"=>{controller: "a"}, "b"=>{controller: "b"}, "c"=>{controller: "c"}, "d" => {controller: "d"}}
      expect(subject.extract_controllers(list)).to eq(result)
    end
  end

  describe ".normalize_controllers" do
    it "returns list of normalized controllers" do
      allow(described_class).to receive(:normalize_controller_item).with(:a).and_return("ab")
      allow(described_class).to receive(:normalize_controller_item).with(:b).and_return("bc")
      expect(described_class.normalize_controllers([:a, :b])).to eq(["ab", "bc"])
    end
  end

  describe ".normalize_controller_item" do
    describe ":controller" do
      context "when given value is instance of `String`" do
        it "use value as controller name" do
          expect(described_class.normalize_controller_item("a")[:controller]).to eq("a")
        end
      end

      context "when given value is hash" do
        it "does not add controller value" do
          expect(described_class.normalize_controller_item(a: "x")[:controller]).to be nil
        end

        it "does not modify controller value" do
          expect(described_class.normalize_controller_item(controller: "x")[:controller]).to eq("x")
        end
      end
    end

    describe ":name" do
      context "when controller hash does not have name value" do
        it "assigns controller value as name" do
          expect(described_class.normalize_controller_item(controller: "x")[:name]).to eq("x")
        end
      end

      context "when controller hash has name value" do
        it "does not change existing name value" do
          expect(described_class.normalize_controller_item(controller: "x", name: "b")[:name]).to eq("b")
        end
      end
    end

    describe ":url_helper" do
      context "when controller hash does not have neither helper or controller values" do
        it "does not add url helper value" do
          expect(described_class.normalize_controller_item(x: "x")[:url_helper]).to be nil
        end
      end

      context "when controller hash has helper value" do
        it "assigns symbolized helper value" do
          expect(described_class.normalize_controller_item(controller: "x", helper: "b")[:url_helper]).to eq(:b)
        end
      end

      context "when controller hash has controller value" do
        it "assigns convert controller name to url helper" do
          expect(described_class.normalize_controller_item(controller: "a/b")[:url_helper]).to eq(:a_b)
        end
      end
    end

    describe ":items" do
      before do
        allow(described_class).to receive(:normalize_controllers).with(["a", "b"]).and_return(["c", "d"])
      end

      context "when controller hash does not have items value" do
        it "does not add items value" do
          expect(described_class.normalize_controller_item(x: "x")[:items]).to be nil
        end
      end

      context "when controller hash has items value" do
        it "does normalizes items" do
          expect(described_class.normalize_controller_item(x: "x", items: ["a", "b"])[:items]).to eq(["c", "d"])
        end
      end
    end
  end
end
