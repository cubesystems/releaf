require "rails_helper"

describe Releaf::Builders::ShowBuilder, type: :class do
  it "includes `Releaf::Builders::ResourceView`" do
    expect(described_class.ancestors).to include(Releaf::Builders::ResourceView)
  end
end
