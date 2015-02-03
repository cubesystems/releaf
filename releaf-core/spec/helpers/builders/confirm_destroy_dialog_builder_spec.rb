require "spec_helper"

describe Releaf::Builders::ConfirmDestroyDialogBuilder, type: :class do
  class ConfirmDestroyDialogTestHelper < ActionView::Base
    include FontAwesome::Rails::IconHelper
    include Releaf::ButtonHelper
    include Releaf::ApplicationHelper

    def protect_against_forgery?
      true
    end

    def form_authenticity_token
      "xxx"
    end

    def request_forgery_protection_token
      "yyy"
    end
  end

  let(:template){ ConfirmDestroyDialogTestHelper.new }
  let(:object){ Book.new(id: 99, title: "book title") }
  let(:subject){ described_class.new(template) }

  before do
    subject.resource = object
    allow(subject.template).to receive(:controller).and_return(Releaf::BaseController.new)
    allow(subject.controller).to receive(:index_url).and_return("y")
  end

  describe "#section_body" do
    it "returns destroy description content" do
      content = '<div class="body"><i class="fa fa-trash-o"></i><div class="question">Do you want to destroy following object?</div><div class="description">book title</div></div>'
      expect(subject.section_body).to eq(content)
    end
  end

  describe "#footer_primary_tools" do
    it "returns array with cancel and confirm forms" do
      allow(subject).to receive(:cancel_form).and_return("a")
      allow(subject).to receive(:confirm_form).and_return("b")
      expect(subject.footer_primary_tools).to eq(["a", "b"])
    end
  end

  describe "#confirm_form" do
    it "returns confirm form" do
      allow(subject.template).to receive(:url_for).with(action: 'destroy', id: 99, index_url: "y").and_return("x")
      allow(subject.template).to receive(:url_for).with("x").and_return("y") # Rails are double calling url_for ....
      content = '<form class="new_resource" id="new_resource" action="y" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="_method" value="delete" /><input type="hidden" name="yyy" value="xxx" /><button class="button with-icon danger" title="Yes" type="submit"><i class="fa fa-check"></i>Yes</button></form>'
      expect(subject.confirm_form).to eq(content)
    end
  end

  describe "#cancel_form" do
    it "returns cancel form" do
      content = '<form class="new_resource" id="new_resource" action="y" accept-charset="UTF-8" method="get"><input name="utf8" type="hidden" value="&#x2713;" /><button class="button with-icon secondary" title="No" type="submit" data-type="cancel"><i class="fa fa-ban"></i>No</button></form>'
      expect(subject.cancel_form).to eq(content)
    end
  end

  describe "#section_header_text" do
    it "returns correct section header" do
      expect(subject.section_header_text).to eq ("Confirm destroy")
    end
  end
end
