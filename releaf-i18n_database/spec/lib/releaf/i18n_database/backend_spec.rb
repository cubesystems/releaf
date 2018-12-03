require "rails_helper"

describe Releaf::I18nDatabase::Backend do
  let(:translations_store){ Releaf::I18nDatabase::TranslationsStore.new }

  describe ".configure_component" do
    it "adds new `Releaf::I18nDatabase::Configuration` configuration with default config" do
      stub_const("Releaf::I18nDatabase::Backend::DEFAULT_CONFIG", a: :b)
      allow(Releaf::I18nDatabase::Configuration).to receive(:new)
        .with(a: :b).and_return("_new")
      expect(Releaf.application.config).to receive(:add_configuration).with("_new")
      described_class.configure_component
    end
  end

  describe ".reset_cache" do
    it "reset translations cache to backend instance" do
      subject.translations_cache = :x
      allow(described_class).to receive(:backend_instance).and_return(subject)
      expect{ described_class.reset_cache }.to change{ subject.translations_cache }.to(nil)
    end
  end

  describe ".backend_instance" do
    context "when I18n backend has chained backends" do
      it "returns Releaf::I18nDatabase::Backend instance" do
        backends = I18n::Backend::Chain.new(subject, I18n::Backend::Simple.new)
        allow(I18n).to receive(:backend).and_return(backends)
        expect(described_class.backend_instance).to eq(subject)
      end

      it "returns nil when chain hasn't Releaf::I18nDatabase::Backend instance" do
        backends = I18n::Backend::Chain.new(I18n::Backend::Simple.new)
        allow(I18n).to receive(:backend).and_return(backends)
        expect(described_class.backend_instance).to be nil
      end
    end

    context "when I18n backend has single backend and it is instance of Releaf::I18nDatabase::Backend" do
      it "returns Releaf::I18nDatabase::Backend instance" do
        allow(I18n).to receive(:backend).and_return(subject)
        expect(described_class.backend_instance).to eq(subject)
      end
    end

    context "when I18n backend has single backend and it is not instance of Releaf::I18nDatabase::Backend" do
      it "returns nil" do
        allow(I18n).to receive(:backend).and_return(I18n::Backend::Simple.new)
        expect(described_class.backend_instance).to be nil
      end
    end
  end

  describe ".initialize_component" do
    it "adds itself as i18n backend as primary backend while keeping Rails default simple backend as secondary" do
      allow(I18n).to receive(:backend).and_return(:current_backend)
      allow(I18n::Backend::Chain).to receive(:new).with(:new_backend, :current_backend).and_return(:x)
      allow(described_class).to receive(:new).and_return(:new_backend)
      expect(I18n).to receive(:backend=).with(:x)
      described_class.initialize_component
    end
  end

  describe ".locales_pluralizations" do
    it "returns array all pluralization forms for releaf locales" do
      allow(Releaf.application.config).to receive(:all_locales).and_return([:de, :ru])
      allow(I18n).to receive(:t).with(:'i18n.plural.keys', locale: :de).and_return([:one, :other])
      allow(I18n).to receive(:t).with(:'i18n.plural.keys', locale: :ru).and_return([:one, :few, :many])

      expect(described_class.locales_pluralizations).to eq([:one, :other, :few, :many, :zero])
    end
  end

  describe "#translations" do
    let(:another_translations_store){ Releaf::I18nDatabase::TranslationsStore.new }

    context "when translations has been loaded and is not expired" do
      it "returns assigned translations hash instance" do
        subject.translations_cache = translations_store
        allow(translations_store).to receive(:expired?).and_return(false)
        expect(Releaf::I18nDatabase::TranslationsStore).to_not receive(:new)
        expect(subject.translations).to eq(translations_store)
      end
    end

    context "when translations has been loaded and is expired" do
      it "initializes new `TranslationsStore`, cache and return it" do
        subject.translations_cache = translations_store
        allow(translations_store).to receive(:expired?).and_return(true)
        expect(Releaf::I18nDatabase::TranslationsStore).to receive(:new).and_return(another_translations_store)
        expect(subject.translations).to eq(another_translations_store)
      end
    end

    context "when translations has not been loaded" do
      it "initializes new `TranslationsStore`, cache and return it" do
        subject.translations_cache = nil
        expect(Releaf::I18nDatabase::TranslationsStore).to receive(:new).and_return(another_translations_store)
        expect(subject.translations).to eq(another_translations_store)
      end
    end
  end

  describe "#store_translations" do
    it "pass given translations to simple translation backend" do
      simple_backend = I18n.backend.backends.last
      expect(simple_backend).to receive(:store_translations).with(:lv, {a: "x"}, {c: "d"})
      subject.store_translations(:lv, {a: "x"}, {c: "d"})
    end
  end

  describe ".translations_updated_at" do
    it "returns translations updated_at from cached settings" do
      allow(Releaf::Settings).to receive(:[]).with(described_class::UPDATED_AT_KEY).and_return("x")
      expect(described_class.translations_updated_at).to eq("x")
    end
  end

  describe ".translations_updated_at=" do
    it "stores translations updated_at to cached settings" do
      expect(Releaf::Settings).to receive(:[]=).with(described_class::UPDATED_AT_KEY, "xx")
      described_class.translations_updated_at = "xx"
    end
  end

  describe "#lookup" do
    before do
      allow(subject).to receive(:translations).and_return(translations_store)
      allow(subject).to receive(:normalize_flat_keys).with(:lv, "some.localization", "_scope_", ":")
        .and_return("xx.s.loc")
    end

    it "flattens key before passing further" do
      expect(translations_store).to receive(:missing?).with(:lv, "xx.s.loc")
      expect(translations_store).to receive(:lookup).with(:lv, "xx.s.loc", separator: ":", a: "b")
      expect(translations_store).to receive(:missing).with(:lv, "xx.s.loc", separator: ":", a: "b")

      subject.lookup(:lv, "some.localization", "_scope_", separator: ":", a: "b")
    end

    context "when translation is known as missing" do
      it "does not make lookup in translation hash, does not mark it as missing and return nil" do
        allow(translations_store).to receive(:missing?).with(:lv, "xx.s.loc").and_return(true)
        expect(translations_store).to_not receive(:lookup)
        expect(translations_store).to_not receive(:missing)
        expect(subject.lookup(:lv, "some.localization", "_scope_", separator: ":", a: "b")).to be nil
      end
    end

    context "when translation is not known as missing" do
      before do
        allow(translations_store).to receive(:missing?).with(:lv, "xx.s.loc").and_return(false)
      end

      context "when lookup result is not nil" do
        before do
          allow(translations_store).to receive(:lookup).with(:lv, "xx.s.loc", separator: ":", a: "b").and_return("x")
        end

        it "returns lookup result" do
          expect(subject.lookup(:lv, "some.localization", "_scope_", separator: ":", a: "b")).to eq("x")
        end

        it "does not mark translation as missing" do
          expect(translations_store).to_not receive(:missing).with(:lv, "xx.s.loc", separator: ":", a: "b")
          subject.lookup(:lv, "some.localization", "_scope_", separator: ":", a: "b")
        end
      end

      context "when lookup result is nil" do
        before do
          allow(translations_store).to receive(:lookup).with(:lv, "xx.s.loc", separator: ":", a: "b").and_return(nil)
        end

        it "returns nil" do
          expect(subject.lookup(:lv, "some.localization", "_scope_", separator: ":", a: "b")).to be nil
        end

        it "marks translation as missing" do
          expect(translations_store).to receive(:missing).with(:lv, "xx.s.loc", separator: ":", a: "b")
          subject.lookup(:lv, "some.localization", "_scope_", separator: ":", a: "b")
        end
      end
    end

    context "when database doesn't exists" do
      it "returns an empty array" do
        allow(Releaf::I18nDatabase::I18nEntry).to receive(:pluck).and_raise(ActiveRecord::NoDatabaseError.new("xxx"))
        expect(subject.lookup(:lv, "some.localization", "_scope_", separator: ":", a: "b")).to be nil
      end
    end

    context "when node table doesn't exist" do
      it "returns an empty array" do
        allow(Releaf::I18nDatabase::I18nEntry).to receive(:pluck).and_raise(ActiveRecord::StatementInvalid.new("xxx"))
        expect(subject.lookup(:lv, "some.localization", "_scope_", separator: ":", a: "b")).to be nil
      end
    end
  end
end
