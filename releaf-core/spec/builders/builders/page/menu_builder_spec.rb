require "spec_helper"

describe Releaf::Builders::Page::MenuBuilder, type: :class do
  class MenuBuilderTestHelper < ActionView::Base
  end

  let(:template){ MenuBuilderTestHelper.new }
  subject { described_class.new(template) }


  it "includes Releaf::Builders::Base" do
    expect(described_class.ancestors).to include(Releaf::Builders::Base)
  end

  it "includes Releaf::Builders::Template" do
    expect(described_class.ancestors).to include(Releaf::Builders::Template)
  end

  describe "#output" do
    pending
  end

  describe "#menu_level" do
    pending
  end

  describe "#menu_item" do
    pending
  end

  describe "#collapsed_item?" do
    pending
  end

  describe "#item_attributes" do
    pending
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
    pending
  end

  describe "#compacter" do
    pending
  end

end