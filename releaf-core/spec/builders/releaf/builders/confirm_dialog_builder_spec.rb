require "rails_helper"

describe Releaf::Builders::ConfirmDialogBuilder, type: :class do
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

  class ConfirmDialogBuilderInheriter < Releaf::Builders::ConfirmDialogBuilder
    def confirm_url; end
    def icon_name; end
    def question_content; end
    def description_content; end
    def confirm_method; end
  end

  let(:template){ ConfirmDestroyDialogTestHelper.new }
  let(:object){ Book.new(id: 99, title: "book title") }
  let(:subject){ ConfirmDialogBuilderInheriter.new(template) }

  before do
    subject.resource = object
    allow(subject.template).to receive(:controller).and_return(Releaf::ActionController.new)
    allow(subject.controller).to receive(:index_path).and_return("y")
  end

  describe "#section_body" do
    it "returns destroy description content" do
      allow(subject).to receive(:section_body_blocks).and_return(["a", "b"])
      content = '<div class="body">ab</div>'
      expect(subject.section_body).to eq(content)
    end
  end

  describe "#section_body_blocks" do
    it "returns section body blocks" do
      allow(subject).to receive(:icon_name).and_return("circle")
      allow(subject).to receive(:question_content).and_return("question")
      allow(subject).to receive(:description_content).and_return("description")

      allow(subject).to receive(:icon).with("circle").and_return("ikon")
      allow(subject).to receive(:tag).with(:div, "question", class: "question").and_return("question")
      allow(subject).to receive(:tag).with(:div, "description", class: "description").and_return("description")
      expect(subject.section_body_blocks).to eq(["ikon", "question", "description"])
    end
  end

  describe "#section_attributes" do
    it "adds `confirm` class" do
      expect(subject.section_attributes[:class]).to include("confirm")
    end
  end

  describe "#footer_primary_tools" do
    it "returns array with cancel and confirm forms" do
      allow(subject).to receive(:cancel_button).and_return("a")
      allow(subject).to receive(:confirm_button).and_return("b")
      expect(subject.footer_primary_tools).to eq(["a", "b"])
    end
  end

  describe "#confirm_form_options" do
    it "returns confirm form options" do
      allow(subject).to receive(:confirm_url).and_return("x")
      allow(subject).to receive(:confirm_method).and_return("tt")
      expect(subject.confirm_form_options).to eq(builder: Releaf::Builders::FormBuilder, url: "x", as: :resource, method: "tt")
    end
  end

  describe "#confirm_button" do
    it "returns confirm button" do
      allow(subject).to receive(:t).with("Yes").and_return("Yess")
      allow(subject).to receive(:button).with("Yess", "check", class: "danger", type: "submit").and_return("x")
      expect(subject.confirm_button).to eq("x")
    end
  end

  describe "#cancel_path" do
    it "returns index path" do
      allow(subject).to receive(:index_path).and_return("x")
      expect(subject.cancel_path).to eq("x")
    end
  end

  describe "#cancel_button" do
    it "returns cancel button" do
      allow(subject).to receive(:cancel_path).and_return("xasd")
      allow(subject).to receive(:t).with("No").and_return("Noo")
      allow(subject).to receive(:button).with("Noo", "ban", class: "secondary", data: {type: "cancel"}, href: "xasd")
        .and_return("x")
      expect(subject.cancel_button).to eq("x")
    end
  end
end
