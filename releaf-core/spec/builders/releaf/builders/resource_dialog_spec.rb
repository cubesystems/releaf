require "rails_helper"

describe Releaf::Builders::ResourceDialog, type: :class do
  class DialogTestHelper < ActionView::Base
  end

  class UnitTestDialogBuilder
    include Releaf::Builders::Base
    include Releaf::Builders::Template
    include Releaf::Builders::ResourceDialog
  end

  subject { UnitTestDialogBuilder.new(template) }
  let(:template){ DialogTestHelper.new }

  describe "#dialog?" do
    it "always returns true" do
      expect(subject.dialog?).to be true
    end
  end
end
