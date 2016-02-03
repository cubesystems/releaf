require "rails_helper"

describe Releaf::Permissions::SettingsManager do
  let(:controller){ Releaf::RootController.new }
  let(:user){ Releaf::Permissions::User.new }

  before do
    allow(user.settings).to receive(:[]).with("asd.a").and_return("lalal")
    allow(controller).to receive(:user).and_return(user)
  end

  describe ".configure_component" do
    it "registers itself as settings manager" do
      expect(Releaf.application.config).to receive(:settings_manager=).and_return(described_class)
      described_class.configure_component
    end
  end

  describe ".read" do
    it "returns user settings for given key" do
      expect(described_class.read(controller: controller, key: "asd.a")).to eq("lalal")
    end

    context "when controller has no user method" do
      it "returns nil" do
        allow(controller).to receive(:respond_to?).with(:user).and_return(false)
        expect(described_class.read(controller: controller, key: "asd.a")).to be nil
      end
    end
  end

  describe ".write" do
    it "writes user settings for given key and value" do
      expect(user.settings).to receive(:[]=).with("asd.a", "op")
      described_class.write(controller: controller, key: "asd.a", value: "op")
    end
  end
end
