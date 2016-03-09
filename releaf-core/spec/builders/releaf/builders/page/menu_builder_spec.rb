require "rails_helper"

describe Releaf::Builders::Page::MenuBuilder, type: :class do
  class MenuBuilderTestHelper < ActionView::Base
    include FontAwesome::Rails::IconHelper
  end

  let(:controller){ Releaf::ActionController.new }
  let(:template){ MenuBuilderTestHelper.new }
  let(:group_item){ Releaf::ControllerGroupDefinition.new(name: "_group_name", items: []) }
  let(:controller_item){ Releaf::ControllerDefinition.new(name: "y", controller: "_controller_") }
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
      allow(Releaf.application.config).to receive(:menu).and_return("_menu_config")
      allow(subject).to receive(:compacter).and_return("cmpt")
      allow(subject).to receive(:menu_level).with("_menu_config").and_return("_items")

      expect(subject.output).to eq("cmpt<nav>_items</nav>")
    end
  end

  describe "#active?" do
    context "when item is instance of `Releaf::ControllerGroupDefinition`" do
      before do
        allow(subject).to receive(:active?).and_call_original
        allow(group_item).to receive(:controllers).and_return([:a, :b, :c])
      end

      context "when any of group item controller is active" do
        it "returns true" do
          allow(subject).to receive(:active?).with(:a).and_return(false)
          allow(subject).to receive(:active?).with(:b).and_return(true)
          expect(subject).to_not receive(:active?).with(:c)
          expect(subject.active?(group_item)).to be true
        end
      end

      context "when none of group item controller is active" do
        it "returns false" do
          allow(subject).to receive(:active?).with(:a).and_return(false)
          allow(subject).to receive(:active?).with(:b).and_return(false)
          allow(subject).to receive(:active?).with(:c).and_return(false)
          expect(subject.active?(group_item)).to be false
        end
      end
    end

    context "when item is instance of `Releaf::ControllerDefinition`" do
      context "when item controller name is same as current controller short name" do
        it "returns true" do
          allow(controller).to receive(:short_name).and_return("_controller_")
          expect(subject.active?(controller_item)).to be true
        end
      end

      context "when item controller name is not same as current controller short name" do
        it "returns false" do
          allow(controller).to receive(:short_name).and_return("_another_controller_")
          expect(subject.active?(controller_item)).to be false
        end
      end
    end
  end

  describe "#menu_level" do
    it "returns unordered list of menu level from given items" do
      allow(subject).to receive(:menu_item).with("a").and_return("_a_")
      allow(subject).to receive(:menu_item).with("b").and_return("_b_")
      expect(subject.menu_level(%w(a b))).to eq("<ul>_a__b_</ul>")
    end

    context "when all menu items content is empty" do
      it "returns nil" do
        allow(subject).to receive(:menu_item).with("a").and_return(nil)
        allow(subject).to receive(:menu_item).with("b").and_return(nil)
        expect(subject.menu_level(%w(a b))).to be nil
      end
    end
  end

  describe "#menu_item" do
    before do
      allow(subject).to receive(:item_attributes).with(controller_item).and_return(class: "red")
      allow(subject).to receive(:menu_item_single).with(controller_item).and_return("_item")
      allow(subject).to receive(:item_attributes).with(group_item).and_return(class: "blue")
      allow(subject).to receive(:menu_item_group).with(group_item).and_return("_items_group")
    end

    context "when item is instance of `Releaf::ControllerDefinition`" do
      it "returns single menu item" do
        expect(subject.menu_item(controller_item)).to eq("<li class=\"red\">_item</li>")
      end
    end

    context "when item is instance of `Releaf::ControllerGroupDefinition`" do
      it "returns group menu item" do
        expect(subject.menu_item(group_item)).to eq("<li class=\"blue\">_items_group</li>")
      end
    end
  end

  describe "#menu_item_single" do
    it "returns single menu item" do
      allow(controller_item).to receive(:path).and_return("_url")
      allow(subject).to receive(:item_name_content).with(controller_item).and_return("_name")
      expect(subject.menu_item_single(controller_item)).to eq("<a class=\"trigger\" href=\"_url\">_name</a>")
    end
  end

  describe "#menu_item_group" do
    it "returns group menu item" do
      allow(group_item).to receive(:controllers).and_return(["a"])
      allow(subject).to receive(:item_collapser).with(group_item).and_return("_collapser")
      allow(subject).to receive(:item_name_content).with(group_item).and_return("_name")
      allow(subject).to receive(:menu_level).with(["a"]).and_return("_level")
      expect(subject.menu_item_group(group_item)).to eq("<span class=\"trigger\">_name_collapser</span>_level")
    end
  end

  describe "#collapsed_item?" do
    before do
      allow(subject).to receive(:layout_settings).with("releaf.menu.collapsed._group_name").and_return(true)
      allow(subject).to receive(:active?).with(group_item).and_return(false)
    end

    context "when non-active and permanently collapsed group item given" do
      it "returns true" do
        expect(subject.collapsed_item?(group_item)).to be true
      end
    end

    context "when non-active and non-permanently collapsed group item given" do
      it "returns false" do
        allow(subject).to receive(:layout_settings).with("releaf.menu.collapsed._group_name").and_return(false)
        expect(subject.collapsed_item?(group_item)).to be false

        allow(subject).to receive(:layout_settings).with("releaf.menu.collapsed._group_name").and_return(nil)
        expect(subject.collapsed_item?(group_item)).to be false
      end
    end

    context "when active and permanently collapsed group item given" do
      it "returns false" do
        allow(subject).to receive(:active?).with(group_item).and_return(true)
        expect(subject.collapsed_item?(group_item)).to be false
      end
    end

    context "when non-active and permanently collapsed single item given" do
      it "returns false" do
        expect(subject).to_not receive(:active?)
        expect(subject.collapsed_item?(controller_item)).to be false
      end
    end
  end

  describe "#item_attributes" do
    it "returns data name and classes within hash" do
      allow(subject).to receive(:item_classes).with(controller_item).and_return(["ol", "al"])
      expect(subject.item_attributes(controller_item)).to eq(class: ["ol", "al"], data: {name: "y"})
    end

    context "when classes attribute is empty" do
      it "does not return class attribute within returned hash" do
        allow(subject).to receive(:item_classes).with(controller_item).and_return([])
        expect(subject.item_attributes(controller_item)).to_not include(:class)
      end
    end
  end

  describe "#item_classes" do
    context "when given item is active" do
      it "adds `active` class to returned array" do
        allow(subject).to receive(:active?).with(controller_item).and_return(true)
        expect(subject.item_classes(controller_item)).to include("active")
      end
    end

    context "when given item is collapsed" do
      it "adds `collapsed` class to returned array" do
        allow(subject).to receive(:collapsed_item?).with(controller_item).and_return(true)
        expect(subject.item_classes(controller_item)).to include("collapsed")
      end
    end

    context "when no extra classes added" do
      it "returns empty array" do
        allow(subject).to receive(:active?).with(controller_item).and_return(false)
        expect(subject.item_classes(controller_item)).to eq([])
      end
    end
  end

  describe "#item_name_content" do
    it "returns abbreviation and full name elements" do
      allow(controller_item).to receive(:localized_name).and_return('Item full name')
      allow(subject).to receive(:item_name_abbreviation).with('Item full name').and_return('Item abbreviation')
      expect( subject.item_name_content(controller_item) ).to eq('<abbr title="Item full name">Item abbreviation</abbr><span class="name">Item full name</span>')
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
