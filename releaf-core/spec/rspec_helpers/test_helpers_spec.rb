require "rails_helper"

describe Releaf::Test::Helpers do
  describe ".stub_settings" do
    it "stubs given hash by key, value to Releaf::Settings" do
      stub_settings("some.settings" => "x", "something" => "nothing")
      expect(Releaf::Settings["some.settings"]).to eq("x")
      expect(Releaf::Settings["something"]).to eq("nothing")
    end

    it "mergs multiple stub calls" do
      stub_settings("some.settings" => "x")
      stub_settings("another.settings" => "xx")

      expect(Releaf::Settings["some.settings"]).to eq("x")
      expect(Releaf::Settings["another.settings"]).to eq("xx")
      expect(Releaf::Settings["unrelated.settings"]).to eq(nil)
    end
  end
end
