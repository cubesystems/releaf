require "rails_helper"

describe Releaf::Builders::FormBuilder::Associations, type: :class do
  class FormBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
    include Releaf::ButtonHelper
    include FontAwesome::Rails::IconHelper
  end

  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Book.new }
  let(:subject){ Releaf::Builders::FormBuilder.new(:book, object, template, {}) }

  describe "#reflect_on_association" do
    it "returns reflection for given reflection name" do
      expect(subject.reflect_on_association(:author)).to eq(object.class.reflections["author"])
      expect(subject.reflect_on_association("author")).to eq(object.class.reflections["author"])
    end
  end

  describe "#association_reflector" do
    before do
      resource_fields = subject.resource_fields
      allow(resource_fields).to receive(:association_attributes).with(:x).and_return([:c, :d])

      allow(subject).to receive(:resource_fields).and_return(resource_fields)
      allow(subject).to receive(:sortable_column_name).and_return("sortable column name")
    end

    it "returns association reflector for given reflection" do
      expect(subject.association_reflector(:x, [:a, :b])).to be_instance_of Releaf::Builders::AssociationReflector
    end

    it "pass reflection, fields and sortable column name to association reflector constructor" do
      expect(Releaf::Builders::AssociationReflector).to receive(:new)
        .with(:x, [:a, :b], "sortable column name")
      subject.association_reflector(:x, [:a, :b])
    end

    context "when given fields is nil" do
      it "uses resource fields returned association fields instead" do
        expect(Releaf::Builders::AssociationReflector).to receive(:new)
          .with(:x, [:c, :d], "sortable column name")
        subject.association_reflector(:x, nil)
      end
    end
  end

  describe "#releaf_association_fields" do
    let(:reflector){ Releaf::Builders::AssociationReflector.new(:a, :b, :c) }
    let(:fields){ ["a"] }

    before do
      allow(subject).to receive(:association_reflector).with(:author, fields).and_return(reflector)
      allow(subject).to receive(:releaf_has_many_association).with(reflector).and_return("_has_many_content_")
      allow(subject).to receive(:releaf_belongs_to_association).with(reflector).and_return("_belongs_to_content_")
      allow(subject).to receive(:releaf_has_one_association).with(reflector).and_return("_has_one_content_")
    end

    context "when reflector macro is :has_many" do
      it "renders association with #releaf_has_many_association" do
        allow(reflector).to receive(:macro).and_return(:has_many)
        expect(subject.releaf_association_fields(:author, fields)).to eq("_has_many_content_")
      end
    end

    context "when :belongs_to association given" do
      it "renders association with #releaf_belongs_to_association" do
        allow(reflector).to receive(:macro).and_return(:belongs_to)
        expect(subject.releaf_association_fields(:author, fields)).to eq("_belongs_to_content_")
      end
    end

    context "when :has_one association given" do
      it "renders association with #releaf_has_one_association" do
        allow(reflector).to receive(:macro).and_return(:has_one)
        expect(subject.releaf_association_fields(:author, fields)).to eq("_has_one_content_")
      end
    end

    context "when non implemented assocation type given" do
      it "raises error" do
        allow(reflector).to receive(:macro).and_return(:new_macro_type)
        expect{ subject.releaf_association_fields(:author, fields) }.to raise_error("not implemented")
      end
    end
  end

  describe "#releaf_item_field_choices" do
    before do
      collection = [Author.new(name: "a", surname: "b", id: 1), Author.new(name: "c", surname: "d", id: 2)]
      allow(subject).to receive(:releaf_item_field_collection)
        .with(:author_id, x: "a").and_return(collection)
    end

    context "when no select_options passed within options" do
      it "returns corresponding collection array" do
        expect(subject.releaf_item_field_choices(:author_id, x: "a")).to eq([["a b", 1], ["c d", 2]])
      end
    end

    context "when options have select_options passed" do
      it "returns `select_options` value" do
        expect(subject.releaf_item_field_choices(:author_id, select_options: "xx")).to eq("xx")
      end
    end
  end

  describe "#releaf_item_field_collection" do
    context "when collection exists within options" do
      it "returns collection" do
        expect(subject.releaf_item_field_collection(:author_id, collection: "x")).to eq("x")
      end
    end

    context "when collection does not exist within options" do
      it "returns all relation objects" do
        allow(Author).to receive(:all).and_return("y")
        expect(subject.releaf_item_field_collection(:author_id)).to eq("y")
      end
    end
  end

  describe "#relation_name" do
    it "strips _id from given string and returns it as symbol" do
      expect(subject.relation_name("admin_id")).to eq(:admin)
    end
  end
end
