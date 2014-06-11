require "spec_helper"

describe Releaf::AssetsResolver do
  describe ".stylesheet_exists?" do
    context "when stylesheet exists for given releaf controller" do
      it "returns true" do
        expect(Releaf::AssetsResolver.stylesheet_exists?("releaf/i18n_database/translations")).to be true
      end
    end

    context "when stylesheet does not exist for given releaf controller" do
      it "returns false" do
        expect(Releaf::AssetsResolver.stylesheet_exists?("releaf/admins")).to be false
      end
    end
  end

  describe ".javascript_exists?" do
    context "when javascript exists for given releaf controller" do
      it "returns true" do
        expect(Releaf::AssetsResolver.javascript_exists?("releaf/i18n_database/translations")).to be true
      end
    end

    context "when stylesheet does not exist for given releaf controller" do
      it "returns false" do
        expect(Releaf::AssetsResolver.javascript_exists?("releaf/admins")).to be false
      end
    end
  end
end
