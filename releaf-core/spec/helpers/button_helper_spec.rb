require 'rails_helper'

describe Releaf::ButtonHelper do

  describe "#releaf_button" do

    it "returns an HTML button element with title, icon, text and optional extra attributes" do
      output = '<button class="button with-icon danger secondary" title="escape&gt;&lt;this" type="button" autocomplete="off" data-x="escape&lt;this&gt;too"><i class="fa fa-plus"></i>escape&gt;&lt;this</button>'
      expect(helper.releaf_button("escape><this", "plus", class: [ :danger, "secondary" ], 'data-x' => 'escape<this>too' )).to eq(output)
    end

    it "uses #releaf_button_attributes and #releaf_button_content to collect button attributes and content" do
      processed_attributes = { attr: :value, data: { attrx: "valuex" } }

      expect(helper).to receive(:releaf_button_attributes).with("foo", "bar", {} ).and_return(processed_attributes)
      expect(helper).to receive(:releaf_button_content).with("foo", "bar", processed_attributes).and_return("button content")

      expect(helper.releaf_button("foo", "bar")).to eq('<button attr="value" data-attrx="valuex">button content</button>')
    end

    context "when href is given in attributes" do

      it "returns a link element instead of a button" do
        html = '<a class="button with-icon" title="x" href="http://example.com/?a&amp;b"><i class="fa fa-plus"></i>x</a>'
        expect(helper.releaf_button("x", "plus", href: "http://example.com/?a&b")).to eq(html)
      end

      it "returns a link element even if the given href is blank" do
        html = '<a class="button with-icon" title="x"><i class="fa fa-plus"></i>x</a>'
        expect(helper.releaf_button("x", "plus", href: nil)).to eq(html)
      end

    end

  end

  describe "#releaf_button_attributes" do

    it "returns a hash of attributes" do
      expect(helper.releaf_button_attributes( :text_foo, :icon_bar )).to be_a Hash
    end

    it "adds button class" do
      expect(helper.releaf_button_attributes( :text_foo, :icon_bar )[:class]).to include( "button" )
    end

    it "sets title attribute to given text" do
      expect(helper.releaf_button_attributes( :text_foo, :icon_bar )).to include( title: :text_foo )
    end

    context "when href attribute given" do
      it "does not set type attribute" do
        expect(helper.releaf_button_attributes( :text_foo, :icon_bar, href: :baz )).to_not include( :type )
      end
    end

    context "when href attribute not given" do
      it "sets type attribute to button" do
        expect(helper.releaf_button_attributes( :text_foo, :icon_bar )).to include( type: :button )
      end
    end

    context "when icon given" do

      context "when text also given" do
        it "adds with-icon class" do
          expect(helper.releaf_button_attributes( :text_foo, :icon_bar )[:class]).to include( "with-icon" )
        end
      end

      context "when text not given" do
        it "adds only-icon class" do
          expect(helper.releaf_button_attributes( nil, :icon_bar )[:class]).to include( "only-icon" )
        end
      end

    end

    context "when extra attributes given" do

      it "includes given custom attributes with the default ones" do
        expect(helper.releaf_button_attributes( :text_foo, :icon_bar, data: { x: "y" })).to include( class: ["button", "with-icon"], data: { x: "y" } )
      end

      it "overwrites default attributes if needed" do
        expect(helper.releaf_button_attributes( :text_foo, :icon_bar, type: :submit, title: "custom")).to include( type: :submit, title: "custom" )
      end

      it "combines given class names with the deault ones" do
        expect(helper.releaf_button_attributes( :text_foo, :icon_bar, class: "danger") ).to include( class: ["button", "with-icon", "danger"] )
      end

    end

  end


  describe "#releaf_button_content" do

    let(:icon_html) { '<i class="fa fa-icon_bar"></i>' }

    it "returns an html-safe buffer" do
      expect(helper.releaf_button_content( :text_foo, :icon_bar )).to be_a ActiveSupport::SafeBuffer
    end

    context "when text and icon given" do
      it "returns icon HTML followed by given text" do
        expect(helper.releaf_button_content( "escape<this>text", :icon_bar )).to eq(icon_html + 'escape&lt;this&gt;text')
      end
    end

    context "when only text given" do
      it "returns given text" do
        expect(helper.releaf_button_content( "escape<this>text", nil )).to eq('escape&lt;this&gt;text')
      end
    end

    context "when only icon given" do

      context "when title attribute is present" do
        it "returns icon HTML" do
          expect(helper.releaf_button_content( nil, :icon_bar, title: "foo" )).to eq(icon_html)
        end
      end

      context "when title attribute is not present" do

        it "raises an ArgumentError" do
          expect{ helper.releaf_button_content(nil, :icon_bar, title: "") }.to raise_error(ArgumentError, "Title is required for icon-only buttons")
        end

      end

    end


    context "when both text and icon are blank" do
      it "raises an ArgumentError" do
        expect{ helper.releaf_button_content(nil, nil ) }.to raise_error(ArgumentError, "Either text or icon is required for buttons")
        expect{ helper.releaf_button_content("", "" ) }.to raise_error(ArgumentError, "Either text or icon is required for buttons")
      end
    end

  end

end
