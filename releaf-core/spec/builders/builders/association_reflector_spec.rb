require 'rails_helper'

describe Releaf::Builders::AssociationReflector, type: :class do
  let(:reflection){ Book.reflect_on_association("chapters") }
  subject{ described_class.new(reflection, :b, "xx") }

  describe "#initialize" do
    it "assigns given reflection" do
      expect(subject.reflection).to eq(reflection)
    end

    it "assigns given fields" do
      expect(subject.fields).to eq(:b)
    end

    it "normalizes to symbol and assigns given sortable name" do
      expect(subject.sortable_column_name).to eq(:xx)
    end
  end

  describe "#destroyable?" do
    context "when reflection allow to destroy through nested attributes" do
      it "returns true" do
        subject.reflection = Book.reflect_on_association("book_sequels")
        expect(subject.destroyable?).to be true
      end
    end

    context "when reflection does not allow to destroy through nested attributes" do
      it "returns false" do
        expect(subject.destroyable?).to be false
      end
    end

    it "caches result" do
      expect(subject.reflection.active_record).to receive(:nested_attributes_options).and_call_original.once
      subject.destroyable?
      subject.destroyable?
      subject.destroyable?
    end
  end

  describe "#sortable?" do
    context "when expected and actual order clauses are same" do
      it "returns true" do
        allow(subject).to receive(:expected_order_clause).and_return(:a)
        allow(subject).to receive(:actual_order_clause).and_return(:a)
        expect(subject.sortable?).to be true
      end
    end

    context "when expected and actual order clauses differs" do
      it "returns false" do
        allow(subject).to receive(:expected_order_clause).and_return(:a)
        allow(subject).to receive(:actual_order_clause).and_return(:b)
        expect(subject.sortable?).to be false
      end
    end

    it "caches result" do
      expect(subject).to receive(:expected_order_clause).and_return(:x).once
      expect(subject).to receive(:actual_order_clause).and_return(:y).once
      subject.sortable?
      subject.sortable?
      subject.sortable?
    end
  end

  describe "#actual_order_clause" do
    context "when scope exists within reflection" do
      it "returns actual reflection klass order clause with evaluated scope" do
        relation = reflection.klass.all.order(:item_position)
        allow(subject).to receive(:extract_order_clause).with(relation).and_return(:y)
        expect(subject.actual_order_clause).to eq(:y)
      end
    end

    context "when no scope exists within reflection" do
      it "returns actual reflection klass order clause" do
        subject.reflection = Book.reflect_on_association("sequels")
        relation = subject.reflection.klass.all
        allow(subject).to receive(:extract_order_clause).with(relation).and_return(:y)
        expect(subject.actual_order_clause).to eq(:y)
      end
    end
  end

  describe "#expected_order_clause" do
    it "returns expected reflection klass order clause for sortable column name" do
      subject.sortable_column_name = :title
      relation = reflection.klass.all.order(:title)
      allow(subject).to receive(:extract_order_clause).with(relation).and_return(:y)
      expect(subject.expected_order_clause).to eq(:y)
    end
  end

  describe "#extract_order_clause" do
    it "returns order clauses normalized to string for given relation" do
      relation = Book.order(genre: :desc)
      expected_result = if mysql?
                          "`books`.`genre` DESC"
                        elsif postgresql?
                          '"books"."genre" DESC'
                        else
                          fail
                        end
      expect(subject.extract_order_clause(relation)).to eq(expected_result)
    end

    context "when relation has no order clauses" do
      it "returns empty string" do
        relation = Book.all
        expect(subject.extract_order_clause(relation)).to eq("")
      end
    end
  end

  describe "#value_as_sql" do
    context "when given value respond to sql" do
      it "return resulting sql" do
        expected_result = if mysql?
                            "SELECT `books`.* FROM `books`"
                          elsif postgresql?
                            'SELECT "books".* FROM "books"'
                          else
                            fail
                          end
        expect(subject.value_as_sql(Book.all)).to eq(expected_result)
      end
    end

    context "when given value does not respond to sql" do
      it "return given value" do
        expect(subject.value_as_sql(12)).to eq(12)
      end
    end
  end
end
