require "spec_helper"

describe Releaf::Core::DefaultSearchableFields do
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
        ]
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
end
