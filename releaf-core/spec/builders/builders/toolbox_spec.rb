require "rails_helper"

describe Releaf::Builders::Toolbox, type: :class do
  class ToolboxTestTemplate < ActionView::Base
  end

  class UnitTestToolboxBuilder
    include Releaf::Builders::Base
    include Releaf::Builders::Template
    include Releaf::Builders::Toolbox
  end

  subject { UnitTestToolboxBuilder.new(template) }
  let(:template){ ToolboxTestTemplate.new }
  let(:resource){ Releaf::Permissions::User.new }

  describe "#toolbox" do
    context "when passed object is new record" do
      it "returns empty string" do
        expect(subject.toolbox(resource)).to eq("")
      end
    end

    context "when passed object is existing record" do
      it "returns empty string" do
        resource.id = 212
        allow(resource).to receive(:new_record?).and_return(false)
        allow(subject).to receive(:t).with("Tools").and_return("tls")
        allow(subject).to receive(:icon).with("ellipsis-v lg").and_return("kebab_icon")
        allow(subject).to receive(:icon).with("caret-up lg").and_return("caret_icon")
        allow(subject).to receive(:action_name).and_return("edit")
        allow(subject).to receive(:url_for).with({action: :toolbox, id: 212, context: "edit", some_param: 89}).and_return("/toolbox_action")

        expect(subject.toolbox(resource, some_param: 89).gsub(/\s/,'')).to eq(%Q{<divclass=\"toolboxuninitialized\"data-url=\"/toolbox_action\"><buttondisabled=\"disabled\"class=\"buttontriggeronly-icon\"type=\"button\"title=\"tls\">kebab_icon</button><menuclass=\"toolbox-items\"type=\"toolbar\">caret_icon<ul></ul></menu></div>}.gsub(/\s/,''))
      end
    end
  end
end
