require 'spec_helper'

describe Releaf::ApplicationHelper do
  Color = Struct.new(:id, :to_s)

  before do
    group = FactoryGirl.create(:translation_group, :scope => "admin.global")
    translation = FactoryGirl.create(:translation, :key => "admin.global.colors-red", :translation_group => group)
    FactoryGirl.create(:translation_data, :lang => "en", :localization => "Color red", :translation => translation)
    Settings.i18n_updated_at = Time.now

    helper.stub(:controller_scope_name).and_return("admin.global")
  end

  describe "#i18n_options_for_select" do
    context "when array of string" do
      it "returns translated options" do
        input = ["red", "green", "blue"]
        output = ['<option value="red">Color red</option>', '<option value="green" selected="selected">green</option>', '<option value="blue">blue</option>'].join("\n")
        expect(helper.i18n_options_for_select(input, "green", "colors")).to eq(output)
      end
    end

    context "when hash" do
      it "returns translated options" do
        input = {"red" => "r", "green" => "g", "blue" => "b"}
        output = ['<option value="r">Color red</option>', '<option value="g" selected="selected">green</option>', '<option value="b">blue</option>'].join("\n")
        expect(helper.i18n_options_for_select(input, "g", "colors")).to eq(output)
      end
    end

    context "when array of string for another translation scope" do
      it "returns translated options" do
        input = ["red", "green", "blue"]
        output = ['<option value="red">red</option>', '<option value="green" selected="selected">green</option>', '<option value="blue">blue</option>'].join("\n")
        expect(helper.i18n_options_for_select(input, "green", "colors", {:scope => "admin.products"})).to eq(output)
      end
    end
  end
end
