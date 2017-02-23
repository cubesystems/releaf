require "rails_helper"

class DummyModel
  include ActiveModel::Validations
  attr_accessor :name, :surname, :age
  validates :name, presence: {error_code: :no_name}
  validates :surname, presence: true
end

describe "Extend ActiveModel validation error with error_code attribute" do
  let(:item) do
    item = DummyModel.new
    item.valid?
    item
  end

  it "adds ActiveModel::ErrorMessage as error instead of String" do
    expect(item.errors.get(:name).first.class).to eq(ActiveModel::ErrorMessage)
  end

  it "does not owerwrite default error message behaviour" do
    expect(item.errors.get(:name).first).to eq("can't be blank")
  end

  context "when validation have :error_code option" do
    it "adds :error_code value as error_code" do
      expect(item.errors.get(:name).first.error_code).to eq(:no_name)
    end
  end

  context "when validation message is symbol" do
    it "adds message as error_code" do
      expect(item.errors.get(:surname).first.error_code).to eq(:blank)
    end
  end

  context "when validation message is not symbol and don't have :error_code option" do
    it "adds :invalid as error_code" do
      item.errors.add(:age, Proc.new {"no age"})
      expect(item.errors.get(:age).first.error_code).to eq(:invalid)
    end
  end

  context "when error with :strict option added" do
    it "raises ActiveModel::StrictValidationFailed error" do
      expect { item.errors.add(:age, :invalid, strict: true) }.to raise_error(ActiveModel::StrictValidationFailed)
    end
  end

  context "when error with :data option is added" do
    it "stores data" do
      item.errors.add(:age, :invalid, data: {foo: :bar})
      expect( item.errors.get(:age).first.data ).to eq(foo: :bar)
    end
  end
end
