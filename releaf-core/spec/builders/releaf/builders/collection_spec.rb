require "rails_helper"

describe Releaf::Builders::Collection, type: :module do
  class CollectionIncluder
    include Releaf::Builders::Base
    include Releaf::Builders::Template
    include Releaf::Builders::Collection
  end
  class CollectionTestHelper < ActionView::Base
  end

  it "it assigns template collection instance variable to instance 'collection' accessor on initialization" do
    template = CollectionTestHelper.new
    template.instance_variable_set("@collection", "x")
    subject = CollectionIncluder.new(template)
    expect(subject.collection).to eq("x")
  end
end
