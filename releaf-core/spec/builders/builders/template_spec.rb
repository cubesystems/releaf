require "rails_helper"

describe Releaf::Builders::Template, type: :module do
  class TemplateClassIncluder
    include Releaf::Builders::Template
  end

  it "it assigns template argument to instance 'template' accessor on initialization" do
    subject = TemplateClassIncluder.new("x")
    expect(subject.template).to eq("x")
  end
end
