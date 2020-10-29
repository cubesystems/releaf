require "rails_helper"

describe Releaf::Content::Node::Service do
  class DummyNodeServiceIncluder
    include Releaf::Content::Node::Service
  end

  let(:node){ Node.new }
  subject{ DummyNodeServiceIncluder.new(node: node) }

  describe "#add_error_and_raise" do
    it "adds errors to base and raise validation error" do
      expect{ subject.add_error_and_raise("shit happen") }.to raise_error do |exception|
        expect(exception).to be_instance_of ActiveRecord::RecordInvalid
        expect(exception.record.errors[:base]).to eq(["shit happen"])
      end
    end
  end
end
