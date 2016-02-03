require "rails_helper"

describe  Releaf::Root::SettingsManager do
  let(:controller){ Releaf::RootController.new }
  let(:cookies){ {"asd.a" => "lalal"} }

  before do
    allow(controller).to receive(:send).with(:cookies).and_return(cookies)
  end

  describe ".read" do
    it "returns cookies settings for given key" do
      expect(described_class.read(controller: controller, key: "asd.a")).to eq("lalal")
    end
  end

  describe ".write" do
    it "writes user settings for given key and value" do
      expect{ described_class.write(controller: controller, key: "asd.a", value: "op") }.to change{ cookies["asd.a"] }.to("op")
    end
  end
end
