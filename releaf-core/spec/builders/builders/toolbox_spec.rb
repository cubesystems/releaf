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
    context "when the passed object is a new record" do
      it "returns empty string" do
        expect(subject.toolbox(resource)).to eq("")
      end
    end

    context "when the passed object is an existing record" do
      it "returns toolbox HTML with trigger and without items" do
        resource.id = 212
        allow(resource).to receive(:new_record?).and_return(false)
        allow(subject).to receive(:t).with("Tools").and_return("tls")
        allow(subject).to receive(:icon).with("ellipsis-v").and_return("<kebab_icon />".html_safe)
        allow(subject).to receive(:icon).with("caret-up").and_return("<caret_icon />".html_safe)
        allow(subject).to receive(:action_name).and_return("edit")
        allow(subject).to receive(:url_for).with({action: :toolbox, id: 212, context: "edit", some_param: 89}).and_return("/toolbox_action")

        expect(subject.toolbox(resource, some_param: 89)).to match_html(%Q[
          <div class="toolbox" data-url="/toolbox_action">
            <button class="button trigger only-icon" type="button" title="tls">
              <kebab_icon />
            </button>
            <menu class="toolbox-items" type="toolbar">
              <caret_icon />
              <ul></ul>
            </menu>
        </div>
        ])
      end
    end
  end
end
