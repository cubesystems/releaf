# encoding: UTF-8

require "spec_helper"

describe Releaf::Node do
  let(:node) { Releaf::Node.new }

  specify "model validations" do
    expect(node).to have(1).error_on(:name)
    expect(node).to have(1).error_on(:slug)
    expect(node).to have(1).error_on(:content_type)
  end

  describe "after save" do
    it "set node update to current time" do
      Settings['nodes.updated_at'] = Time.now
      time_now = Time.parse("2009-02-23 21:00:00 UTC")
      Time.stub(:now).and_return(time_now)

      expect{ FactoryGirl.create(:node) }.to change{ Settings['nodes.updated_at'] }.to(time_now)
    end
  end

  describe "#destroy" do
    before do
      @node = FactoryGirl.create(:node)
    end

    it "set node update to current time" do
      @time_now = Time.parse("2009-02-23 21:00:00 UTC")
      Time.stub(:now).and_return(@time_now)
      expect{ @node.destroy }.to change{ Settings['nodes.updated_at'] }.to(@time_now)
    end
  end

  describe ".updated_at" do
    it "returns last node update" do
      time_now = Time.now
      Time.stub(:now).and_return(time_now)
      FactoryGirl.create(:node)

      expect(Releaf::Node.updated_at).to eq(time_now)
    end
  end
end
