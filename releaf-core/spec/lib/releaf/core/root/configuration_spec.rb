require "rails_helper"

describe Releaf::Core::Root::Configuration do
  it do
    subject.default_controller_resolver = "asd"
    is_expected.to have_attributes(default_controller_resolver: "asd")
  end
end
