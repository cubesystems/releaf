require "rails_helper"

describe Releaf::Builders::Page::MenuBuilder, type: :class do
  class MenuBuilderTestHelper < ActionView::Base
    include FontAwesome::Rails::IconHelper
  end

  let(:controller){ Releaf::BaseController.new }
  let(:template){ MenuBuilderTestHelper.new }
  subject { described_class.new(template) }

  before do
    allow(template).to receive(:controller).and_return(controller)
  end

  it "includes Releaf::Builders::Base" do
    expect(described_class.ancestors).to include(Releaf::Builders::Base)
  end

  it "includes Releaf::Builders::Template" do
    expect(described_class.ancestors).to include(Releaf::Builders::Template)
  end

  describe "#output" do
    it "returns compacter and first level menu" do
      allow(subject).to receive(:compacter).and_return("cmpt")
      allow(subject).to receive(:menu_items).and_return("_items")
      allow(subject).to receive(:menu_level).with("_items").and_return("_items")

      expect(subject.output).to eq("cmpt<nav>_items</nav>")
    end
  end

  describe "#menu_items" do
    it "returns menu items build from menu config" do
      allow(Releaf.application.config).to receive(:menu).and_return("_menu_config")
      allow(subject).to receive(:build_items).with("_menu_config").and_return("_items")
      expect(subject.menu_items).to eq("_items")
    end
  end

  describe "#build_items" do
    it "returns list of build items" do
      allow(subject).to receive(:build_item).with("a").and_return("aa")
      allow(subject).to receive(:build_item).with("b").and_return("bb")
      allow(subject).to receive(:build_item).with("c").and_return("cc")
      expect(subject.build_items(%w(a b c))).to eq(%w(aa bb cc))
    end
  end

  describe "#build_item" do
    context "when item is single item" do
      it "returns single item built from given item duplicate" do
        item = {some: "thing"}
        allow(item).to receive(:dup).and_return("_dup")
        allow(subject).to receive(:build_single_item).with("_dup").and_return("x")
        expect(subject.build_item(item)).to eq("x")
      end
    end

    context "when item is group" do
      it "returns items group built from given item duplicate" do
        item = {some: "thing", items: [1, 2]}
        allow(item).to receive(:dup).and_return("_dup")
        allow(subject).to receive(:build_items_group).with("_dup").and_return("x")
        expect(subject.build_item(item)).to eq("x")
      end
    end
  end

  describe "#build_single_item" do
    it "adds active value to given item" do
      item = {controller: "home"}
      allow(subject).to receive(:active_controller?).with("home").and_return("_active")
      expect(subject.build_single_item(item)).to eq(controller: "home", active: "_active")
    end
  end

  describe "#build_items_group" do
    let(:item){ {name: "xx", items: ["a", "b"]} }
    let(:items){ [{url_helper: "_h1", active: false}, {url_helper: "_h2", active: false}] }

    context "when item group has items" do
      before do
        allow(subject).to receive(:build_items).with(["a", "b"]).and_return(items)
        allow(subject).to receive(:active_items?).with(items).and_return("_active")
      end

      it "adds processed group items, activity value and first item url helper" do
        expect(subject.build_items_group(item)).to eq(name: "xx", items: items, active: "_active", url_helper: "_h1")
      end
    end

    context "when item group has no items" do
      it "returns given item with empty items attribute" do
        allow(subject).to receive(:build_items).with(["a", "b"]).and_return([])
        expect(subject.build_items_group(item)).to eq(name: "xx", items: [])
      end
    end
  end

  describe "#active_items?" do
    context "when given items has active item" do
      it "returns true" do
        items = [{active: false}, {active: true}]
        expect(subject.active_items?(items)).to be true
      end
    end

    context "when given items has no active item" do
      it "returns false" do
        items = [{active: false}, {active: false}]
        expect(subject.active_items?(items)).to be false
      end
    end
  end

  describe "#active_controller?" do
    context "when given controller name is same as current controller short name" do
      it "returns true" do
        allow(controller).to receive(:short_name).and_return("_shrt_name")
        expect(subject.active_controller?("_shrt_name")).to be true
      end
    end

    context "when given controller name is other than current controller short name" do
      it "returns false" do
        allow(controller).to receive(:short_name).and_return("as")
        expect(subject.active_controller?("_shrt_name")).to be false
      end
    end
  end

  describe "#menu_level" do
    it "returns unordered list of menu level from given items" do
      allow(subject).to receive(:menu_item).with("a").and_return("_a_")
      allow(subject).to receive(:menu_item).with("b").and_return("_b_")
      expect(subject.menu_level(%w(a b))).to eq("<ul>_a__b_</ul>")
    end
  end

  describe "#menu_item" do
    context "when single item given" do
      it "returns single menu item" do
        item = {a: "x"}
        allow(subject).to receive(:item_attributes).with(item).and_return(class: "red")
        allow(subject).to receive(:menu_item_single).with(item).and_return("_item")
        expect(subject.menu_item(item)).to eq("<li class=\"red\">_item</li>")
      end
    end

    context "when group item given" do
      it "returns group menu item" do
        item = {a: "x", items: ["a"]}
        allow(subject).to receive(:item_attributes).with(item).and_return(class: "red")
        allow(subject).to receive(:menu_item_group).with(item).and_return("_items_group")
        expect(subject.menu_item(item)).to eq("<li class=\"red\">_items_group</li>")
      end
    end
  end

  describe "#menu_item_single" do
    it "returns single menu item" do
      item = {url_helper: "x"}
      allow(subject).to receive(:url_for).with("x").and_return("_url")
      allow(subject).to receive(:item_name_content).with(item).and_return("_name")
      expect(subject.menu_item_single(item)).to eq("<a class=\"trigger\" href=\"_url\">_name</a>")
    end
  end

  describe "#menu_item_group" do
    it "returns group menu item" do
      item = {url_helper: "x", items: ["a"]}
      allow(subject).to receive(:item_collapser).with(item).and_return("_collapser")
      allow(subject).to receive(:item_name_content).with(item).and_return("_name")
      allow(subject).to receive(:menu_level).with(["a"]).and_return("_level")
      expect(subject.menu_item_group(item)).to eq("<span class=\"trigger\">_name_collapser</span>_level")
    end
  end

  describe "#collapsed_item?" do
    let(:item){ {items: ["a"], active: false, name: "_name"} }

    before do
      allow(subject).to receive(:layout_settings).with("releaf.menu.collapsed._name").and_return(true)
    end

    context "when non-active and permanently collapsed group item given" do
      it "returns true" do
        expect(subject.collapsed_item?(item)).to be true
      end
    end

    context "when non-active and non-permanently collapsed group item given" do
      it "returns false" do
        allow(subject).to receive(:layout_settings).with("releaf.menu.collapsed._name").and_return(false)
        expect(subject.collapsed_item?(item)).to be false

        allow(subject).to receive(:layout_settings).with("releaf.menu.collapsed._name").and_return(nil)
        expect(subject.collapsed_item?(item)).to be false
      end
    end

    context "when active and permanently collapsed group item given" do
      it "returns false" do
        item[:active] = true
        expect(subject.collapsed_item?(item)).to be false
      end
    end

    context "when non-active and permanently collapsed single item given" do
      it "returns false" do
        item[:items] = nil
        expect(subject.collapsed_item?(item)).to be false
      end
    end
  end

  describe "#item_attributes" do
    let(:item){ {name: "loko"} }

    it "returns data name and classes within hash" do
      allow(subject).to receive(:item_classes).with(item).and_return(["ol", "al"])
      expect(subject.item_attributes(item)).to eq(class: ["ol", "al"], data: {name: "loko"})
    end

    context "when classes attribute is empty" do
      it "does not return class attribute within returned hash" do
        allow(subject).to receive(:item_classes).with(item).and_return([])
        expect(subject.item_attributes(item)).to_not include(:class)
      end
    end
  end

  describe "#item_classes" do
    let(:item){ {active: false} }

    context "when given item is active" do
      it "adds `active` class to returned array" do
        item[:active] = true
        expect(subject.item_classes(item)).to include("active")
      end
    end

    context "when given item is collapsed" do
      it "adds `collapsed` class to returned array" do
        allow(subject).to receive(:collapsed_item?).with(item).and_return(true)
        expect(subject.item_classes(item)).to include("collapsed")
      end
    end

    context "when no extra classes added" do
      it "returns empty array" do
        expect(subject.item_classes(item)).to eq([])
      end
    end
  end

  describe "#item_name_content" do
    let(:item) { { name: :item_name } }

    it "returns abbreviation and full name elements" do
      allow(subject).to receive(:t).with( :item_name, scope: "admin.controllers" ).and_return('Item full name')
      allow(subject).to receive(:item_name_abbreviation).with('Item full name').and_return('Item abbreviation')
      expect( subject.item_name_content( item ) ).to eq('<abbr title="Item full name">Item abbreviation</abbr><span class="name">Item full name</span>')
    end
  end

  describe "#item_name_abbreviation" do

    it "returns first two letters of given text string" do
      expect( subject.item_name_abbreviation( "Foo bar" )).to eq("Fo")
    end

    context "when the first two letters are lowercase" do
      it "capitalizes the first letter" do
        expect( subject.item_name_abbreviation( "foo bar" )).to eq("Fo")
      end
    end

    context "when the first two letters are uppercase" do
      it "makes the second letter lowercase" do
        expect( subject.item_name_abbreviation( "FOO BAR" )).to eq("Fo")
      end
    end

    context "when the string contains slashes" do

      it "uses the first word after the last slash" do
        expect( subject.item_name_abbreviation( "Releaf/core/settings" )).to eq("Se")
      end

      it "ignores slashes surrounded by spaces" do
        expect( subject.item_name_abbreviation( "Inputs / Outputs" )).to eq("In")
      end

      it "ignores trailing slashes" do
        expect( subject.item_name_abbreviation( "Releaf/core/settings/" )).to eq("Se")
      end

      context "when string consists of a single slash" do
        it "returns an empty string" do
          expect( subject.item_name_abbreviation( "/" )).to eq("")
        end
      end
    end

    it "works with non-latin characters" do
      expect( subject.item_name_abbreviation( "žņ" )).to eq("Žņ")
    end

    context "when given an empty string value" do
      it "returns an empty string" do
        expect( subject.item_name_abbreviation( "" )).to eq("")
      end
    end

    context "when given nil" do
      it "returns an empty string" do
        expect( subject.item_name_abbreviation( nil )).to eq("")
      end
    end
  end

  describe "#item_collapser" do

    it "returns a collapser span with a button and collapser icon" do
      allow(subject).to receive(:item_collapser_icon).with(:foo).and_return(subject.icon('dummy'))
      expect(subject.item_collapser(:foo)).to eq '<span class="collapser"><button type="button"><i class="fa fa-dummy"></i></button></span>'
    end

  end

  describe "#item_collapser_icon" do
    let(:item) { {} }

    before do
      allow(subject).to receive(:layout_settings).with('releaf.side.compact').and_return(false)
    end

    context "when side is compacted in layout settings" do
      it "returns a beak pointing right" do
        allow(subject).to receive(:layout_settings).with('releaf.side.compact').and_return(true)
        allow(subject).to receive(:icon).with('chevron-right').and_return("icon ok")
        expect(subject.item_collapser_icon(item)).to eq "icon ok"
      end
    end

    context "when side is not compacted in layout settings" do
      context "when the given item is collapsed" do
        it "returns a beak pointing down" do
          allow(subject).to receive(:collapsed_item?).with(item).and_return(true)
          allow(subject).to receive(:icon).with('chevron-down').and_return("icon ok")
          expect(subject.item_collapser_icon(item)).to eq "icon ok"
        end
      end
      context "when the given item is expanded" do
        it "returns a beak pointing up" do
          allow(subject).to receive(:collapsed_item?).with(item).and_return(false)
          allow(subject).to receive(:icon).with('chevron-up').and_return("icon ok")
          expect(subject.item_collapser_icon(item)).to eq "icon ok"
        end
      end
    end
  end

  describe "#compact_side?" do
    it "returns layout settings for `releaf.side.compact`" do
      allow(subject).to receive(:layout_settings).with("releaf.side.compact").and_return("_ls")
      expect(subject.compact_side?).to eq("_ls")
    end
  end

  describe "#compacter" do
    before do
      allow(subject).to receive(:button)
        .with(nil, "angle-double-right", title: "Expand", data: {"title-expand"=>"Expand", "title-collapse"=>"Collapse"})
        .and_return("_expand_btn")
      allow(subject).to receive(:button)
        .with(nil, "angle-double-left", title: "Collapse", data: {"title-expand"=>"Expand", "title-collapse"=>"Collapse"})
        .and_return("_collapse_btn")
    end

    context "when compact mode" do
      it "returns expanding button" do
        allow(subject).to receive(:compact_side?).and_return(true)
        expect(subject.compacter).to eq("<div class=\"compacter\">_expand_btn</div>")
      end
    end

    context "when non-compact mode" do
      it "returns collapsing button" do
        allow(subject).to receive(:compact_side?).and_return(false)
        expect(subject.compacter).to eq("<div class=\"compacter\">_collapse_btn</div>")
      end
    end
  end
end
