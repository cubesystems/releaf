require "rails_helper"

describe Releaf::Root::Configuration do
  subject{ described_class.new(default_controller_resolver: "asd") }

  it do
    is_expected.to have_attributes(default_controller_resolver: "asd")
  end
end
