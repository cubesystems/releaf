require 'spec_helper'

describe Releaf::ApplicationHelper do
  Color = Struct.new(:id, :to_s)

  before do
    translation = FactoryGirl.create(:translation, :key => "admin.global.colors-red")
    FactoryGirl.create(:translation_data, :lang => "en", :localization => "Color red", :translation => translation)
    I18n.backend.reload_cache

    helper.stub(:controller_scope_name).and_return("admin.global")
  end

  describe "#i18n_options_for_select" do
    context "when array of string" do
      it "returns translated options" do
        input = ["red", "green", "blue"]
        output = ['<option value="red">Color red</option>', '<option selected="selected" value="green">green</option>', '<option value="blue">blue</option>'].join("\n")
        expect(helper.i18n_options_for_select(input, "green", "colors")).to eq(output)
      end
    end

    context "when hash" do
      it "returns translated options" do
        input = {"red" => "r", "green" => "g", "blue" => "b"}
        output = ['<option value="r">Color red</option>', '<option selected="selected" value="g">green</option>', '<option value="b">blue</option>'].join("\n")
        expect(helper.i18n_options_for_select(input, "g", "colors")).to eq(output)
      end
    end

    context "when array of string for another translation scope" do
      it "returns translated options" do
        input = ["red", "green", "blue"]
        output = ['<option value="red">red</option>', '<option selected="selected" value="green">green</option>', '<option value="blue">blue</option>'].join("\n")
        expect(helper.i18n_options_for_select(input, "green", "colors", {:scope => "admin.products"})).to eq(output)
      end
    end
  end
end
