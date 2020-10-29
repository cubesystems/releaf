require "rails_helper"

describe Releaf::ControllerGroupDefinition do
  subject{ described_class.new(name: "xxx", items: [:a, :b]) }

  before do
    allow(Releaf::ControllerDefinition).to receive(:new).with(:a).and_return("c_a")
    allow(Releaf::ControllerDefinition).to receive(:new).with(:b).and_return("c_b")
  end

  describe "#initialize" do
    it "assigns `name` option value" do
      expect(subject.name).to eq("xxx")
    end

    it "assigns array with initialized `Releaf::ControllerDefinition` items built from `items` option value" do
      expect(subject.controllers).to eq(["c_a", "c_b"])
    end
  end

  describe "#localized_name" do
    it "returns localized name" do
      allow(I18n).to receive(:t).with("xxx", scope: "admin.controllers").and_return("poiugasd")
      expect(subject.localized_name).to eq("poiugasd")
    end
  end

  describe "#group?" do
    it "returns true" do
      expect(subject.group?).to be true
    end
  end
end
