require "spec_helper"

describe Releaf::Permissions::ProfileFormBuilder, type: :class do
  class FormBuilderTestHelper < ActionView::Base; end
  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Releaf::Permissions::User.new }
  let(:subject){ described_class.new(:resource, object, template, {}) }

  it "inherits Releaf::Permissions::UserFormBuilder" do
    expect(described_class.superclass).to eq(Releaf::Permissions::UserFormBuilder)
  end

  describe "#field_names" do
    it "returns name, surname, locale, email, password and password_confirmation as field names array" do
      expect(subject.field_names).to eq(%w(name surname locale email password password_confirmation))
    end
  end
end
