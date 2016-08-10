require "rails_helper"

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
    allow(subject.template).to receive(:controller).and_return(Releaf::ActionController.new)
    allow(subject.controller).to receive(:index_path).and_return("y")
  end

  describe "#question_content" do
    it "localized destroy question" do
      allow(subject).to receive(:t).with("Do you want to delete the following object?").and_return("xx")
      expect(subject.question_content).to eq("xx")
    end
  end

  describe "#description_content" do
    it "returns `resource_title` value" do
      allow(subject).to receive(:resource_title).with(object).and_return("xx")
      expect(subject.description_content).to eq("xx")
    end
  end

  describe "#section_body" do
    it "returns destroy description content" do
      content = '<div class="body"><i class="fa fa-trash-o"></i><div class="question">Do you want to delete the following object?</div><div class="description">book title</div></div>'
      expect(subject.section_body).to eq(content)
    end
  end

  describe "#confirm_method" do
    it "returns :delete" do
      expect(subject.confirm_method).to eq(:delete)
    end
  end

  describe "#icon_name" do
    it "returns trash icon" do
      expect(subject.icon_name).to eq("trash-o")
    end
  end

  describe "#confirm_url" do
    it "returns resource destroy url" do
      allow(subject.template).to receive(:url_for).with(action: 'destroy', id: 99, index_path: "y").and_return("x")
      expect(subject.confirm_url).to eq("x")
    end
  end
end
