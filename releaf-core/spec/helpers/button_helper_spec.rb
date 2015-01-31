require 'spec_helper'

describe Releaf::ButtonHelper do
  describe "#releaf_button" do
    it "returns button element with title, icon and text" do
      output = '<button class="button with-icon" title="x" type="button"><i class="fa fa-plus"></i>x</button>'
      expect(helper.releaf_button("x", "plus")).to eq(output)
    end

    it "output given attributes within button" do
      output = '<button class="button with-icon" title="x" type="button" data-color="red"><i class="fa fa-plus"></i>x</button>'
      expect(helper.releaf_button("x", "plus", data: {color: "red"})).to eq(output)
    end

    it "merges given class attributes with default value" do
      output = '<button class="button with-icon primary danger" title="x" type="button"><i class="fa fa-plus"></i>x</button>'
      expect(helper.releaf_button("x", "plus", class: ["primary", "danger"])).to eq(output)
    end

    context "when no text given" do
      it "adds only-icon class" do
        output = '<button class="button only-icon" title="y" type="button"><i class="fa fa-plus"></i></button>'
        expect(helper.releaf_button(nil, "plus", title: "y")).to eq(output)
      end

      context "when title is blank or nil" do
        it "raises ArgumentError" do
          expect{ helper.releaf_button(nil, "plus") }.to raise_error(ArgumentError, "Title missing for icon-only button/link")
          expect{ helper.releaf_button(nil, "plus", title: "") }.to raise_error(ArgumentError, "Title missing for icon-only button/link")
        end
      end
    end

    context "when href exists within given attributes" do
      it "returns link" do
        output = '<a class="button with-icon" title="x" href="http://example.com"><i class="fa fa-plus"></i>x</a>'
        expect(helper.releaf_button("x", "plus", href: "http://example.com")).to eq(output)
      end
    end
  end
end
