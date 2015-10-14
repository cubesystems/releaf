require "spec_helper"

describe Releaf::Core::Configuration do
  describe "#configure" do
    it "calls all initializators" do
      expect(subject).to receive(:initialize_defaults).ordered
      expect(subject).to receive(:initialize_locales).ordered
      expect(subject).to receive(:initialize_controllers).ordered
      expect(subject).to receive(:initialize_components).ordered
      subject.configure
    end
  end

  describe "#assets_resolver" do
    it "returns assets resolver class" do
      allow(subject).to receive(:assets_resolver_class_name).and_return("Book")
      expect(subject.assets_resolver).to eq(Book)
    end
  end

  describe "#access_control_module" do
    it "returns access control module class" do
      allow(subject).to receive(:access_control_module_name).and_return("Book")
      expect(subject.access_control_module).to eq(Book)
    end
  end

  describe "#initialize_defaults" do
    it "ovewrites only nil values with default ones" do
      allow(subject).to receive(:default_values).and_return(menu: "aa", components: "lk")
      subject.menu = "x"
      subject.components = nil
      expect{ subject.initialize_defaults }.to change{ [subject.menu, subject.components] }.to(["x", "lk"])
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

    it "merges unique locales form admin and available locales, casts it to strings and assign to `all_locales`" do
      expect{ subject.initialize_locales }.to change{ subject.all_locales }.to eq(["a", "b", "c"])
    end
  end

  describe "#initialize_components" do
    before do
      class DummyComponentA; end
      class DummyComponentB
        def self.initialize_component; end
      end
      allow(subject).to receive(:flatten_components).with(["x", "s"])
        .and_return([DummyComponentA, DummyComponentB])
      subject.components = ["x", "s"]
    end

    it "reassign normalized components" do
      expect{ subject.initialize_components }.to change{ subject.components }.to([DummyComponentA, DummyComponentB])
    end

    it "calls component initializing method if available" do
      expect(DummyComponentB).to receive(:initialize_component)
      subject.initialize_components
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

  describe "#initialize_controllers" do
    before do
      subject.menu = ["a"]
      subject.additional_controllers = ["b"]
      allow(subject).to receive(:normalize_controllers).with(["a"]).and_return(["aa"])
      allow(subject).to receive(:normalize_controllers).with(["b"]).and_return(["bb"])
      allow(subject).to receive(:extract_controllers).with(["aa", "bb"]).and_return({"c" => "d"})
    end

    it "normalizes menu" do
      expect{ subject.initialize_controllers }.to change{ subject.menu }.from(["a"]).to(["aa"])
    end

    it "normalizes additional controllers" do
      expect{ subject.initialize_controllers }.to change{ subject.additional_controllers }.from(["b"]).to(["bb"])
    end

    it "extract controller items from menu and additional controllers and assign then to controllers" do
      expect{ subject.initialize_controllers }.to change{ subject.controllers }.from(nil).to("c" => "d")
    end

    it "extract controller names and assign to available controllers" do
      expect{ subject.initialize_controllers }.to change{ subject.available_controllers }.from(nil).to(["c"])
    end
  end

  describe "#extract_controllers" do
    it "returns recursively built hash with controllers from given array" do
      list = [{controller: "a"}, {items: [{controller: "b"}, {controller: "c"}, {xx: "x"}]}, {controller: "d"}, {asd: "xx"}]
      result = {"a"=>{controller: "a"}, "b"=>{controller: "b"}, "c"=>{controller: "c"}, "d" => {controller: "d"}}
      expect(subject.extract_controllers(list)).to eq(result)
    end
  end

  describe "#normalize_controllers" do
    it "returns list of normalized controllers" do
      allow(subject).to receive(:normalize_controller_item).with(:a).and_return("ab")
      allow(subject).to receive(:normalize_controller_item).with(:b).and_return("bc")
      expect(subject.normalize_controllers([:a, :b])).to eq(["ab", "bc"])
    end
  end

  describe "#normalize_controller_item" do
    describe ":controller" do
      context "when given value is instance of `String`" do
        it "use value as controller name" do
          expect(subject.normalize_controller_item("a")[:controller]).to eq("a")
        end
      end

      context "when given value is hash" do
        it "does not add controller value" do
          expect(subject.normalize_controller_item(a: "x")[:controller]).to be nil
        end

        it "does not modify controller value" do
          expect(subject.normalize_controller_item(controller: "x")[:controller]).to eq("x")
        end
      end
    end

    describe ":name" do
      context "when controller hash does not have name value" do
        it "assigns controller value as name" do
          expect(subject.normalize_controller_item(controller: "x")[:name]).to eq("x")
        end
      end

      context "when controller hash has name value" do
        it "does not change existing name value" do
          expect(subject.normalize_controller_item(controller: "x", name: "b")[:name]).to eq("b")
        end
      end
    end

    describe ":url_helper" do
      context "when controller hash does not have neither helper or controller values" do
        it "does not add url helper value" do
          expect(subject.normalize_controller_item(x: "x")[:url_helper]).to be nil
        end
      end

      context "when controller hash has helper value" do
        it "assigns symbolized helper value" do
          expect(subject.normalize_controller_item(controller: "x", helper: "b")[:url_helper]).to eq(:b)
        end
      end

      context "when controller hash has controller value" do
        it "assigns convert controller name to url helper" do
          expect(subject.normalize_controller_item(controller: "a/b")[:url_helper]).to eq(:a_b)
        end
      end
    end

    describe ":items" do
      before do
        allow(subject).to receive(:normalize_controllers).with(["a", "b"]).and_return(["c", "d"])
      end

      context "when controller hash does not have items value" do
        it "does not add items value" do
          expect(subject.normalize_controller_item(x: "x")[:items]).to be nil
        end
      end

      context "when controller hash has items value" do
        it "does normalizes items" do
          expect(subject.normalize_controller_item(x: "x", items: ["a", "b"])[:items]).to eq(["c", "d"])
        end
      end
    end
  end

  describe "#default_values" do
    it "returns default configuration key, value hash" do
      result = {
        menu: [],
        devise_for: 'releaf/permissions/user',
        additional_controllers: [],
        controllers: {},
        components: [],
        assets_resolver_class_name:  'Releaf::Core::AssetsResolver',
        layout_builder_class_name: 'Releaf::Builders::Page::LayoutBuilder',
        access_control_module_name: 'Releaf::Permissions'
      }
      expect(subject.default_values).to eq(result)
    end
  end
end


