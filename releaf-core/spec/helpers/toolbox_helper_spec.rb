require 'spec_helper'

describe Releaf::ToolboxHelper do
  let(:resource){ Releaf::Permissions::Admin.new }

  describe "#toolbox" do
    context "when passed object is new record" do
      it "returns empty string" do
        expect(helper.toolbox(resource)).to eq("")
      end
    end

    context "when passed object is existing record" do
      it "returns empty string" do
        resource.id = 212
        resource.stub(:new_record?).and_return(false)
        helper.stub(:action_name).and_return("edit")
        helper.stub(:url_for).with({action: "toolbox", id: 212, context: "edit", some_param: 89}).and_return("/toolbox_action")

        expect(helper.toolbox(resource, some_param: 89).gsub(/\s/,'')).to eq(%Q{
        <div class="toolbox" data-url="/toolbox_action">
          <button class="button trigger only-icon" type="button" title="Tools">
            <i class="fa fa-lg fa-cog"></i>
          </button>
          <menu class="block toolbox-items" type="toolbar">
            <i class="fa fa-lg fa-caret-up"></i>
            <ul class="block"></ul>
          </menu>
        </div>}.gsub(/\s/,''))
      end
    end
  end
end
