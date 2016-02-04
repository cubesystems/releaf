require "rails_helper"

describe Releaf::DefaultSearchableFields do
  # emulate klass::Translations
  with_model :SearchableObjectTranslations, scope: :all do
    table do |t|
      t.string :name
    end
  end

  with_model :SearchableObject, scope: :all do
    table do |t|
      t.string :email
      t.string :first_name
      t.string :forename
      t.string :last_name
      t.string :login
      t.string :middle_name
      t.string :name
      t.string :surname
      t.string :title
      t.string :username
      t.string :non_searchable
      t.string :password
      t.integer :size
      t.boolean :bool
      t.text :text
    end

    model do
      # emulate globalize accessors
      def self.translates?
        true
      end
    end
  end

  with_model :NonSearchableObject, scope: :all do
    table do |t|
      t.integer :email
      t.integer :first_name
      t.integer :forename
      t.integer :last_name
      t.integer :login
      t.integer :middle_name
      t.integer :name
      t.integer :surname
      t.integer :title
      t.integer :username
    end
  end

  before(:all) do
    # emulate globalize accessors
    SearchableObject.const_set('Translation', SearchableObjectTranslations)
  end

  subject { described_class.new(SearchableObject) }

  describe "#possible_field_names" do
    it "returns array of possible field names to search" do
      expect( subject.possible_field_names ).to match_array %w[
        email
        first_name
        forename
        last_name
        login
        middle_name
        name
        surname
        title
        username
      ]
    end
  end

  describe "#find" do
    context "when searchable fields exist" do
      it "returns array of searchable string columns" do
        expect( described_class.new(SearchableObject).find ).to match_array %w[
          email
          first_name
          forename
          last_name
          login
          middle_name
          name
          surname
          title
          username
        ] + [translations: %w[name]]
      end
    end

    context "when searchable fields doesn't exist" do
      it "returns array of searchable string columns" do
        expect( described_class.new(NonSearchableObject).find ).to be_blank
      end
    end
  end

  describe "#string_columns" do
    it "returns string columsn of model" do
      expect( subject.string_columns ).to match_array %w[
        email
        first_name
        forename
        last_name
        login
        middle_name
        name
        surname
        title
        username
        non_searchable
        password
      ]
    end
  end

  describe "#has_searchable_translated_string_columns?" do
    context "when #klass isn't translated" do
      it "returns false" do
        allow(SearchableObject).to receive(:translates?).and_return(false)
        expect( subject.has_searchable_translated_string_columns? ).to eq false
      end
    end

    context "when #klass is translated and has translated searchable columns" do
      it "returns true" do
        expect( subject.has_searchable_translated_string_columns? ).to eq true
      end
    end

    context "when #klass is translated but has no translated searchable columns" do
      it "returns false" do
        allow( subject ).to receive(:searchable_translated_string_columns).and_return([])
        expect( subject.has_searchable_translated_string_columns? ).to eq false
      end
    end

  end

  describe "#searchable_translated_string_columns" do
    it "returns translated string columns of klass::Translation" do
      expect( subject.searchable_translated_string_columns ).to match_array %w[name]
    end

    it "caches result" do
      searchable_fields = double(described_class)
      expect( searchable_fields ).to receive(:find).once.and_return []

      subject # init subject

      allow( described_class ).to receive(:new).with(SearchableObject::Translation).and_return(searchable_fields)

      subject.searchable_translated_string_columns
      subject.searchable_translated_string_columns
    end
  end
end
