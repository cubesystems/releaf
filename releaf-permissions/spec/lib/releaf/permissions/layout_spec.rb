require "rails_helper"

describe Releaf::Permissions::Layout do
  describe ".initialize_component" do
    it "changes layout_builder_class_name to `Releaf::Permissions::Page::LayoutBuilder`" do
      expect(Releaf.application.config).to receive(:layout_builder_class_name=).with("Releaf::Permissions::Page::LayoutBuilder")
      described_class.initialize_component
    end
  end
end
