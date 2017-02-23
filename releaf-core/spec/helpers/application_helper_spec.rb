require 'rails_helper'

describe Releaf::ApplicationHelper do
  describe "#releaf_table" do
    it "returns table builder output for collection and resource class with given options" do
      builder = Releaf::Permissions::Users::TableBuilder
      collection = "collection"

      allow(builder).to receive(:new).with(collection, TextPage, subject, toolbox: false).and_call_original
      allow_any_instance_of(builder).to receive(:output).and_return("table")

      expect(releaf_table(collection, TextPage, builder: builder, toolbox: false)).to eq("table")
    end
  end

  describe "#merge_attributes" do
    it "makes deep merge second over first hash" do
      expect(helper.merge_attributes({a: {b: "c"}, d: "e"}, {a: {b: "č"}, f: "x"})).to eq(a: {b: "č"}, d: "e", f: "x")
    end

    it "merges class values from both hashes" do
      expect(helper.merge_attributes({class: ["a", "b"]}, {})[:class]).to eq(["a", "b"])
      expect(helper.merge_attributes({}, {class: "d c"})[:class]).to eq(["d c"])
      expect(helper.merge_attributes({class: ["a", "b"]}, {class: "d c"})[:class]).to eq(["a", "b", "d c"])
    end

    it "removes empty class values on merging" do
      expect(helper.merge_attributes({class: ["a", nil, "b"]}, {class: ["", "c"]})[:class]).to eq(["a", "b", "c"])
    end
  end

  describe "#i18n_options_for_select" do
    Color = Struct.new(:id, :to_s)
    let(:helper) do
      helper = instance_double(Releaf::ActionController)
      helper.extend Releaf::ApplicationHelper
      helper.extend ActionView::Helpers

      helper
    end

    before do
      translation = Releaf::I18nDatabase::I18nEntry.create(key: "admin.xx.colors-red")
      translation.i18n_entry_translation.create(locale: "en", text: "Color red")
      Releaf::I18nDatabase::Backend.reset_cache
      allow(helper).to receive(:controller_scope_name).and_return("admin.xx")
    end

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
