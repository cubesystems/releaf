require 'rails_helper'

describe Releaf::ActionController::Search do
  let(:subject){ DummyActionControllerSearchIncluder.new }

  class DummySearcher < Releaf::Search
  end

  class DummyActionControllerSearchIncluder < Releaf::ActionController
    include Releaf::ActionController::Features
    include Releaf::ActionController::Search

    def resource_class
      Book
    end
  end

  describe "#search" do
    before do
      allow(subject).to receive(:searchable_fields).and_return([:name, :email])
      allow(subject).to receive(:feature_available?).with(:search).and_return(true)

      subject.instance_variable_set(:@collection, "_collection")
      allow(subject).to receive(:searcher_class).and_return(DummySearcher)
      allow(DummySearcher).to receive(:prepare).with(relation: "_collection", fields: [:name, :email], text: "_some")
        .and_return("_collection_with_search")
    end

    context "when feature is enabled, text and searchable fields is not blank" do
      it "replaces collection with searchable collection" do
        expect{ subject.search("_some") }.to change{ subject.instance_variable_get(:@collection) }
          .from("_collection").to("_collection_with_search")
      end
    end

    context "when `show` feature is not available" do
      it "does not replace collection with searchable collection" do
        allow(subject).to receive(:feature_available?).with(:search).and_return(false)
        expect{ subject.search("_some") }.to_not change{ subject.instance_variable_get(:@collection) }
      end
    end

    context "when blank search given" do
      it "does not replace collection with searchable collection" do
        expect{ subject.search("") }.to_not change{ subject.instance_variable_get(:@collection) }
      end
    end

    context "when no search fields exists" do
      it "does not replace collection with searchable collection" do
        allow(subject).to receive(:searchable_fields).and_return([])
        expect{ subject.search("_some") }.to_not change{ subject.instance_variable_get(:@collection) }
      end
    end
  end

  describe "#searcher_class" do
    it "returns `Releaf::Search` class" do
      expect(subject.searcher_class).to eq(Releaf::Search)
    end
  end

  describe "#searchable_fields" do
    let(:searchable_fields){ Releaf::DefaultSearchableFields.new(Author) }

    it "adds itself as helper" do
      expect(subject._helper_methods).to include(:searchable_fields)
    end

    it "returns default searchable fields from `Releaf::DefaultSearchableFields` instance" do
      allow(Releaf::DefaultSearchableFields).to receive(:new).with(Book).and_return(searchable_fields)
      allow(searchable_fields).to receive(:find).and_return("x").once

      expect(subject.searchable_fields).to eq("x")
    end

    it "caches returned searchable fields" do
      allow(Releaf::DefaultSearchableFields).to receive(:new).and_return(searchable_fields)
      expect(searchable_fields).to receive(:find).and_return("x").once
      subject.searchable_fields
      subject.searchable_fields
    end
  end
end
