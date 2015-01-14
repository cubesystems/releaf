require 'spec_helper'

describe Releaf::Builders, type: :class do
  module Admin::Advanced
    class SickBuilder
    end
    class AuthorsController
    end
  end

  class Admin::Advanced::Builders < Releaf::Builders; end

  describe ".builder_class" do
    it "returns builder class for given controller and builder type" do
      expect(described_class.builder_class(Releaf::Permissions::UsersController, :form)).to eq(Releaf::Permissions::Users::FormBuilder)
    end

    context "when custom builder class does not exists for given controller and builder type" do
      it "returns default builder class" do
        expect(described_class.builder_class(Admin::Advanced::AuthorsController, :form)).to eq(Releaf::Builders::FormBuilder)
        allow(described_class).to receive(:default_namespace).and_return("Admin::Advanced")
        expect(described_class.builder_class(Releaf::Permissions::UsersController, :sick)).to eq(Admin::Advanced::SickBuilder)
      end
    end

    context "when custom error throwed" do
      it "reraises it" do
        allow(Object).to receive(:const_get).and_call_original
        allow(Object).to receive(:const_get).with("Admin::Authors::FormBuilder").and_raise(ArgumentError, "xx")
        expect{ described_class.builder_class(Admin::AuthorsController, :form) }.to raise_error(ArgumentError, "xx")

        allow(Object).to receive(:const_get).with("Admin::Authors::FormBuilder").and_raise(NameError, "uninitialized constant asdasd")
        expect{ described_class.builder_class(Admin::AuthorsController, :form) }.to raise_error(NameError, "uninitialized constant asdasd")
      end
    end
  end

  describe ".default_namespace" do
    it "returns own class name" do
      expect(described_class.default_namespace).to eq("Releaf::Builders")
      expect(Admin::Advanced::Builders.default_namespace).to eq("Admin::Advanced::Builders")
    end
  end
end
