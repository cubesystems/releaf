require "rails_helper"

describe Releaf::Core::Root do
  describe ".configure_component" do
    it "adds new `Releaf::Core::Root::Configuration` configuration with default controller resolver and assigns settings manager" do
      allow(Releaf::Core::Root::Configuration).to receive(:new)
        .with(default_controller_resolver: Releaf::Core::Root::DefaultControllerResolver).and_return("_new")
      expect(Releaf.application.config).to receive(:add_configuration).with("_new")
      expect(Releaf.application.config).to receive(:settings_manager=).with(Releaf::Core::Root::SettingsManager)
      described_class.configure_component
    end
  end
end
