require "rails_helper"

describe Releaf::ControllerDefinition do
  subject{ described_class.new(name: "op", controller: "admin/books") }

  describe "#initialize" do
    it "assigns `name` option value" do
      expect(subject.name).to eq("op")
    end

    it "assigns `controller` option value to `controller_name`" do
      expect(subject.controller_name).to eq("admin/books")
    end

    context "when no `name` option value given" do
      it "takes `controller` option value as `name` value" do
        subject = described_class.new(controller: "admin/books")
        expect(subject.name).to eq("admin/books")
      end
    end

    context "when string passed instead of Hash" do
      it "takes string as controller option value" do
        subject = described_class.new("admin/authors")
        expect(subject.controller_name).to eq("admin/authors")
      end
    end
  end

  describe "#localized_name" do
    it "returns localized name" do
      allow(I18n).to receive(:t).with("op", scope: "admin.controllers").and_return("poiugasd")
      expect(subject.localized_name).to eq("poiugasd")
    end
  end

  describe "#path" do
    it "returns controller index path" do
      expect(subject.path).to eq("/admin/books")
    end
  end
end
