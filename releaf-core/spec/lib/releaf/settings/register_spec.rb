require "rails_helper"

describe Releaf::Settings::Register do
  let(:subject){ described_class.new(settings: [{key: "a", type: "boolean"}, {key: "c", type: "text"}]) }

  describe "#call" do
    it "registers normalized settings items" do
      allow(subject).to receive(:normalize).with(key: "a", type: "boolean").and_return("yy")
      allow(subject).to receive(:normalize).with(key: "c", type: "text").and_return("zz")
      expect(subject).to receive(:register).with("yy")
      expect(subject).to receive(:register).with("zz")
      subject.call
    end
  end

  describe "#normalize" do
    before do
      allow(subject.settings_class).to receive(:supported_types).and_return([:boolean, :text])
    end

    it "normalizes type valey to symbol" do
      expect(subject.normalize(key: "x", type: "boolean")).to eq(key: "x", type: :boolean)
    end

    context "when no type given" do
      it "sets `:text` as default type" do
        expect(subject.normalize(key: "x")).to eq(key: "x", type: :text)
      end
    end

    context "when unsupported type given" do
      it "raises `Releaf::Error`" do
        allow(subject.settings_class).to receive(:supported_types).and_return([:mp3, :mp4])
        expect{ subject.normalize(key: "x") }.to raise_error(Releaf::Error, "Unsupported settings type: text")
      end
    end

    context "when dissallowed settings keys given" do
      it "raises `Releaf::Error`" do
        expect{ subject.normalize(key: "x", color: "red") }.to raise_error(Releaf::Error, "Dissallowed settings keys: [:color]")
      end
    end
  end

  describe "#register" do
    before do
      allow(subject.settings_class).to receive(:[]=)
      allow(subject.settings_class.registry).to receive(:update)
      allow(subject).to receive(:write_default?).with(key: "x", default: "_xx").and_return(true)
    end

    it "assigns item to settings registry" do
      expect(subject.settings_class.registry).to receive(:update).with("x" => {key: "x", default: "_xx"})
      subject.register(key: "x", default: "_xx")
    end

    it "stores value to cache and db" do
      expect(subject.settings_class).to receive(:[]=).with("x", "_xx")
      subject.register(key: "x", default: "_xx")
    end

    context "when default write is not permitted" do
      it "does not store default value to db" do
        allow(subject).to receive(:write_default?).with(key: "x").and_return(false)
        expect(subject).to_not receive(:[]=)
        subject.register(key: "x", default: "_xx")
      end
    end
  end

  describe "#allowed_keys" do
    it "returns array with `key`, `default`, `type` and `description`" do
      expect(subject.allowed_keys).to eq([:key, :default, :type, :description])
    end
  end

  describe "#write_default?" do
    before do
      allow(subject).to receive(:table_exists?).and_return(true)
      allow(subject.settings_class).to receive(:find_by).with(var: "xx").and_return(nil)
    end

    context "when database table exists and key does not exist in database" do
      it "returns true" do
        expect(subject.write_default?(key: "xx")).to be true
      end
    end

    context "when database table exists and key does exist in database" do
      it "returns false" do
        allow(subject.settings_class).to receive(:find_by).with(var: "xx").and_return(Author.new)
        expect(subject.write_default?(key: "xx")).to be false
      end
    end

    context "when database table does not exists and key does not exist in database" do
      it "returns false" do
        allow(subject).to receive(:table_exists?).and_return(false)
        expect(subject.write_default?(key: "xx")).to be false
      end
    end
  end

  describe "#table_exists?" do
    before do
      allow(subject.settings_class).to receive(:table_exists?).and_return(true)
    end

    context "when `ActiveRecord::NoDatabaseError` database does not exist" do
      it "returns false" do
        allow(subject.settings_class).to receive(:table_exists?).and_raise(ActiveRecord::NoDatabaseError, "x")
        expect(subject.table_exists?).to be false
      end
    end

    context "when table does not exist" do
      it "returns false" do
        allow(subject.settings_class).to receive(:table_exists?).and_return(false)
        expect(subject.table_exists?).to be false
      end
    end

    context "when table exists" do
      it "returns true" do
        expect(subject.table_exists?).to be true
      end
    end
  end

  describe "#settings_class" do
    it "returns `Releaf::Settings` class" do
      expect(subject.settings_class).to eq(Releaf::Settings)
    end
  end
end
