require "rails_helper"

describe Releaf::Service do
  class DummyServiceIncluder
    include Releaf::Service
    attribute :some, String
    attribute :thing, String

    def call; end
  end

  describe ".call" do
    it "initialize new service instance and return `#call` method value" do
      subject = DummyServiceIncluder.new(some: "asd", thing: "asdasd")
      allow(DummyServiceIncluder).to receive(:new).with(some: "x", thing: "y").and_return(subject)
      allow(subject).to receive(:call).and_return("_x_")
      expect(DummyServiceIncluder.call(some: "x", thing: "y")).to eq("_x_")
    end
  end
end
