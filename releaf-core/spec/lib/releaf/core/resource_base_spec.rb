require "spec_helper"

describe Releaf::Core::ResourceBase do
  subject{ described_class.new(Book) }

  describe "#initialize" do
    it "assigns given class to resource class accessor" do
      expect(subject.resource_class).to eq(Book)
    end
  end

  describe "#excluded_attributes" do
    it "returns array with id, created_at and updated_as" do
      expect(subject.excluded_attributes).to eq(["id", "created_at", "updated_at"])
    end
  end

  describe "#localized_attributes?" do
    context "when resource class has globalize support" do
      it "returns true" do
        expect(subject.localized_attributes?).to be true
      end
    end

    context "when resource class does not have globalize support" do
      it "returns false" do
        allow(subject.resource_class).to receive(:translates?).and_return(false)
        expect(subject.localized_attributes?).to be false
      end
    end
  end

  describe "#localized_attributes" do
    it "returns array of all localized attributes params" do
      allow(subject.resource_class).to receive(:translated_attribute_names).and_return([:title, :summary])
      expect(subject.localized_attributes).to eq(["title", "summary"])
    end
  end

  describe "#associations_attributes" do
    it "returns array with associations attributes within hashes" do
      association_1 = subject.resource_class.reflections[:chapters]
      association_2 = subject.resource_class.reflections[:sequels]

      allow(subject).to receive(:associations).and_return([association_1, association_2])
      allow(subject).to receive(:association_attributes).with(association_1).and_return(["a", "b"])
      allow(subject).to receive(:association_attributes).with(association_2).and_return(["c", "d"])

      expect(subject.associations_attributes).to eq([{chapters: ["a", "b"]}, {sequels: ["c", "d"]}])
    end
  end

  describe "#association_attributes" do
    it "returns association params without association excluded attributes" do
      association = subject.resource_class.reflections[:chapters]
      allow(described_class).to receive(:new).with(association.klass).and_call_original
      allow_any_instance_of(described_class).to receive(:values).and_return(["a", "b", "c"])
      allow(subject).to receive(:association_excluded_attributes).and_return(["b"])
      expect(subject.association_attributes(association)).to eq(["a", "c"])
    end
  end

  describe "#association_excluded_attributes" do
    it "returns `foreign_key` and polymorphic association type key (if exists)" do
      association = subject.resource_class.reflections[:chapters]
      allow(association).to receive(:foreign_key).and_return("b")
      expect(subject.association_excluded_attributes(association)).to eq(["b"])

      allow(association).to receive(:type).and_return("x")
      expect(subject.association_excluded_attributes(association)).to eq(["b", "x"])
    end
  end

  describe "#values" do
    before do
      allow(subject).to receive(:associations_attributes).and_return(["x", "y"])
      allow(subject).to receive(:base_attributes).and_return(["a", "b"])
      allow(subject).to receive(:localized_attributes?).and_return(false)
    end

    it "returns resource params array alongside associations params" do
      expect(subject.values).to eq(["a", "b", "x", "y"])
    end

    context "when `include_associations` is false" do
      it "does not include association params" do
        expect(subject.values(include_associations: false)).to eq(["a", "b"])
      end
    end

    context "when resource has localized attributes" do
      it "returns resource base attributes array alongside localized attributes" do
        allow(subject).to receive(:localized_attributes?).and_return(true)
        allow(subject).to receive(:localized_attributes).and_return(["c", "d"])
        expect(subject.values).to eq(["a", "b", "c", "d", "x", "y"])
      end
    end
  end

  describe "#base_attributes" do
    it "returns array with non-excluded attributes" do
      allow(subject.resource_class).to receive(:column_names).and_return(["a", "b", "c"])
      allow(subject).to receive(:excluded_attributes).and_return(["a"])
      expect(subject.base_attributes).to eq(["b", "c"])

      allow(subject).to receive(:excluded_attributes).and_return(["c"])
      expect(subject.base_attributes).to eq(["a", "b"])
    end
  end

  describe "#associations" do
    it "returns array with includable associations" do
      reflections = subject.resource_class.reflections
      allow(subject).to receive(:includable_association?).with(reflections[:releaf_richtext_attachments]).and_return(false)
      allow(subject).to receive(:includable_association?).with(reflections[:chapters]).and_return(true)
      allow(subject).to receive(:includable_association?).with(reflections[:book_sequels]).and_return(false)
      allow(subject).to receive(:includable_association?).with(reflections[:sequels]).and_return(true)
      allow(subject).to receive(:includable_association?).with(reflections[:author]).and_return(false)
      allow(subject).to receive(:includable_association?).with(reflections[:translations]).and_return(false)

      expect(subject.associations).to eq([reflections[:chapters], reflections[:sequels]])
    end
  end

  describe "#includable_association?" do
    let(:association){ subject.resource_class.reflections[:chapters] }

    context "when given association is :has_many, not excluded, not `ThroughReflection` and has nested_attributes for it" do
      it "returns true" do
        expect(subject.includable_association?(association)).to be true
      end
    end

    context "when given association is not :has_many" do
      it "returns false" do
        allow(association).to receive(:macro).and_return(:belongs_to)
        expect(subject.includable_association?(association)).to be false
      end
    end

    context "when given association is `ThroughReflection`" do
      it "returns false" do
        allow(association).to receive(:class).and_return(ActiveRecord::Reflection::ThroughReflection)
        expect(subject.includable_association?(association)).to be false
      end
    end

    context "when given association has no nested_attributes for it" do
      it "returns false" do
        allow(subject.resource_class).to receive(:nested_attributes_options).and_return({})
        expect(subject.includable_association?(association)).to be false
      end
    end

    context "when given association is within excluded associations" do
      it "returns false" do
        allow(subject).to receive(:excluded_associations).and_return([:chapters])
        expect(subject.includable_association?(association)).to be false
      end
    end
  end

  describe "#excluded_associations" do
    it "returns array with `releaf_richtext_attachments` and `translations`" do
      expect(subject.excluded_associations).to eq([:releaf_richtext_attachments, :translations])
    end
  end
end
