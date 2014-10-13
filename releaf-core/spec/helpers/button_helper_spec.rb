require 'spec_helper'

describe Releaf::ButtonHelper do
  describe "#releaf_button" do
    it "returns button element with title, icon and text" do
      output = '<button class="button" title="x" type="button"><i class="fa fa-plus"></i>x</button>'
      expect(helper.releaf_button("x", "plus")).to eq(output)
    end

    it "output given attributes within button" do
      output = '<button class="button" data-color="red" title="x" type="button"><i class="fa fa-plus"></i>x</button>'
      expect(helper.releaf_button("x", "plus", data: {color: "red"})).to eq(output)
    end

    it "merges given class attributes with default value" do
      output = '<button class="button primary danger" title="x" type="button"><i class="fa fa-plus"></i>x</button>'
      expect(helper.releaf_button("x", "plus", class: ["primary", "danger"])).to eq(output)
    end

    context "when url exists within given attributes" do
      it "returns link" do
        output = '<a class="button" title="x" url="http://example.com"><i class="fa fa-plus"></i>x</a>'
        expect(helper.releaf_button("x", "plus", url: "http://example.com")).to eq(output)
      end
    end
  end
end
