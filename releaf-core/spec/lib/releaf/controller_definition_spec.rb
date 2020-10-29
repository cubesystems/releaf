require "rails_helper"

describe Releaf::ControllerDefinition do
  subject{ described_class.new(name: "op", controller: "admin/books") }

  describe ".for" do
    it "returns definition from applicaiton controller config for given controller name" do
      allow(Releaf.application.config).to receive(:controllers).and_return("xxx" => "yyy")
      expect(described_class.for("xxx")).to eq("yyy")
    end
  end

  describe "#initialize" do
    it "assigns `name` option value" do
      expect(subject.name).to eq("op")
    end

    it "assigns `controller` option value to `controller_name`" do
      expect(subject.controller_name).to eq("admin/books")
    end

    context "when `helper` option value given" do
      it "assigns `helper` option value postfixed with `_path` to helper accessor" do
        subject = described_class.new(controller: "admin/books", helper: "some-route")
        expect(subject.helper).to eq("some-route_path")
      end
    end

    context "when no `helper` option value given" do
      it "does not assign anything to helper accessor" do
        subject = described_class.new(controller: "admin/books")
        expect(subject.helper).to be nil
      end
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
    context "when helper exists" do
      it "returns helper value" do
        subject.helper = "new_admin_chapter_path"
        expect(subject.path).to eq("/admin/chapters/new")
      end
    end

    context "when helper is not set" do
      it "returns controller index path" do
        expect(subject.path).to eq("/admin/books")
      end
    end
  end

  describe "#group?" do
    it "returns false" do
      expect(subject.group?).to be false
    end
  end
end
