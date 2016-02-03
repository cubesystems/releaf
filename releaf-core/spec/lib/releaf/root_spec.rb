require "rails_helper"

describe Releaf::Root do
  describe ".configure_component" do
    it "adds new `Releaf::Root::Configuration` configuration with default controller resolver and assigns settings manager" do
      allow(Releaf::Root::Configuration).to receive(:new)
        .with(default_controller_resolver: Releaf::Root::DefaultControllerResolver).and_return("_new")
      expect(Releaf.application.config).to receive(:add_configuration).with("_new")
      expect(Releaf.application.config).to receive(:settings_manager=).with(Releaf::Root::SettingsManager)
      described_class.configure_component
    end
  end
end
