require "rails_helper"

describe Releaf::Builders::FormBuilder::Label, type: :class do
  class FormBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
    include Releaf::ButtonHelper
    include FontAwesome::Rails::IconHelper
  end

  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Book.new }
  let(:subject){ Releaf::Builders::FormBuilder.new(:book, object, template, {}) }

  describe "#releaf_label" do
    it "passes options :label value to #label_text and use returned value for label text content" do
      allow(subject).to receive(:label_text).with(:color, a: "b").and_return("xx")
      result = '<div class="label-wrap"><label for="book_color">xx</label></div>'

      expect(subject.releaf_label(:color, {}, label: {a: "b"})).to eq(result)
    end

    it "uses #label_attributes for label attributes" do
      allow(subject).to receive(:label_attributes).with(:color, {class: "red"}, {a: "b"}).and_return(class: "red blue")
      result = '<div class="label-wrap"><label class="red blue" for="book_color">Color</label></div>'

      expect(subject.releaf_label(:color, {class: "red"}, {a: "b"})).to eq(result)
    end

    context "when options[:label][:description] is not blank" do
      context "when label has full version" do
        it "includes description" do
          result = '<div class="label-wrap"><label for="book_color">Color</label><div class="description">xxx</div></div>'
          expect(subject.releaf_label(:color, {}, label: {description: "xxx"})).to eq(result)
        end
      end

      context "when label has minimal version" do
        it "does not include description" do
          result = '<label for="book_color">Color</label>'
          expect(subject.releaf_label(:color, {}, label: {minimal: true})).to eq(result)
        end
      end
    end

    context "when options[:label][:minimal] is true" do
      it "returns label tag without wrap element" do
        result = '<label for="book_color">Color</label>'
        expect(subject).to_not receive(:wrapper)
        expect(subject.releaf_label(:color, {}, label: {minimal: true})).to eq(result)
      end
    end

    context "when options[:label][:minimal] is not true" do
      it "returns label tag with wrap element" do
        allow(subject).to receive(:wrapper).with('<label for="book_color">Color</label>', class: "label-wrap").and_return("x")
        expect(subject.releaf_label(:color, {}, label: {minimal: false})).to eq("x")
        expect(subject.releaf_label(:color, {}, label: {minimal: nil})).to eq("x")
        expect(subject.releaf_label(:color, {}, label: {adasd: "xx"})).to eq("x")
      end
    end
  end

  describe "#label_attributes" do
    it "returns unmodified attributes (allow further override by other builders)" do
      expect(subject.label_attributes(:color, {data: "x"}, {})).to eq(data: "x")
    end
  end

  describe "#label_text" do
    it "returns model attributes scoped translated value" do
      allow(subject).to receive(:translate_attribute).with("color").and_return("x")
      expect(subject.label_text(:color)).to eq("x")
    end

    context "when :label_text option exists" do
      context "when :label_text is not blank" do
        it "returns :label_text option" do
          expect(subject.label_text(:color, label_text: "krāsa")).to eq("krāsa")
        end
      end

      context "when :label_text is blank" do
        it "returns translated value" do
          expect(subject.label_text(:color, label_text: nil)).to eq("Color")
          expect(subject.label_text(:color, label_text: "")).to eq("Color")
        end
      end
    end

    context "when :translation_key option exists" do
      context "when :translation_key is not blank" do
        it "passes :translation_key option to translation and return translated value" do
          allow(subject).to receive(:translate_attribute).with("true_color").and_return("x")
          expect(subject.label_text(:color, translation_key: "true_color")).to eq("x")
        end
      end

      context "when :translation_key is blank" do
        it "returns translated value" do
          expect(subject.label_text(:color, translation_key: nil)).to eq("Color")
          expect(subject.label_text(:color, translation_key: "")).to eq("Color")
        end
      end
    end
  end
end
