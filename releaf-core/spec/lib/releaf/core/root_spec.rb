require "rails_helper"

describe Releaf::Core::Root do
  describe ".component_configuration" do
    it "returns new `Releaf::Core::Root::Configuration` instance" do
      allow(Releaf::Core::Root::Configuration).to receive(:new).and_return("_new")
      expect(described_class.component_configuration).to eq("_new")
    end
  end

  describe ".initialize_component" do
    it "assigns core root default controller resolver and settings manager" do
      expect(Releaf.application.config.root).to receive(:default_controller_resolver=).with(Releaf::Core::Root::DefaultControllerResolver)
      expect(Releaf.application.config).to receive(:settings_manager=).with(Releaf::Core::Root::SettingsManager)
      described_class.initialize_component
    end
  end
end
