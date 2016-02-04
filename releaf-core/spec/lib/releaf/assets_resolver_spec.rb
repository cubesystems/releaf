require "rails_helper"

describe Releaf::AssetsResolver do
  describe ".base_assets" do
    it "returns array with `releaf/application`" do
      expect(described_class.base_assets).to eq(["releaf/application"])
    end
  end

  describe ".controller_assets" do
    before do
      allow(described_class).to receive(:base_assets).and_return(["a", "b"])
    end

    it "returns array with controller specific asset alognside base assets" do
      allow(described_class).to receive(:assets).and_return(
        "releaf/i18n_database/translations" => {
          javascripts: ["c"],
          stylesheets: ["d", "e"],
        }
      )
      expect(described_class.controller_assets("releaf/i18n_database/translations", :javascripts))
        .to eq(["a", "b", "c"])
      expect(described_class.controller_assets("releaf/i18n_database/translations", :stylesheets))
        .to eq(["a", "b", "d", "e"])
    end

    context "when no controller specific assets exists" do
      it "returns only base assets" do
        allow(described_class).to receive(:assets).and_return({})
        expect(described_class.controller_assets("releaf/i18n_database/translations", :stylesheets))
          .to eq(["a", "b"])
      end
    end
  end

  describe ".compiled_assets" do
    it "returns array with controller scoped stylesheets and javascripts" do
      allow(Rails.application.assets_manifest).to receive(:files).and_return(
        "releaf/controllers/releaf/content/nodes-72ac849dd467fe827933f15c45ea77a2b7beac55379147f3be4a21779787f484.js"=>{"logical_path"=>"releaf/controllers/releaf/content/nodes.js", "mtime"=>"2015-12-01T13:55:41+02:00", "size"=>1530, "digest"=>"72ac849dd467fe827933f15c45ea77a2b7beac55379147f3be4a21779787f484", "integrity"=>"sha256-cqyEndRn/oJ5M/FcRep3ore+rFU3kUfzvkohd5eH9IQ="},
        "releaf/controllers/releaf/content/nodes-2ac6b38702a01d9e0918f058f923b39c8320cdfa61f41c7494752b648a45e746.css"=>{"logical_path"=>"releaf/controllers/releaf/content/nodes.css", "mtime"=>"2016-01-18T13:36:15+02:00", "size"=>5919, "digest"=>"2ac6b38702a01d9e0918f058f923b39c8320cdfa61f41c7494752b648a45e746", "integrity"=>"sha256-KsazhwKgHZ4JGPBY+SOznIMgzfph9Bx0lHUrZIpF50Y="},
        "releaf/controllers/releaf/permissions/sessions-9eb2f3275ea7578a6a95ca413d318a9984ef93c0d6645f11cf77fe82a2639cf0.css"=>{"logical_path"=>"releaf/controllers/releaf/permissions/sessions.css", "mtime"=>"2016-01-18T13:36:15+02:00", "size"=>2205, "digest"=>"9eb2f3275ea7578a6a95ca413d318a9984ef93c0d6645f11cf77fe82a2639cf0", "integrity"=>"sha256-nrLzJ16nV4pqlcpBPTGKmYTvk8DWZF8Rz3f+gqJjnPA="}
      )

      list = {
        "releaf/content/nodes"=>{:stylesheets=>["releaf/controllers/releaf/content/nodes.css"],
                                 :javascripts=>["releaf/controllers/releaf/content/nodes.js"]},
        "releaf/permissions/sessions" => {:stylesheets=>["releaf/controllers/releaf/permissions/sessions.css"], :javascripts=>[]}
      }
      expect(described_class.compiled_assets).to eq(list)
    end
  end

  describe ".noncompiled_assets" do
    it "returns array with controller scoped stylesheets and javascripts" do
      list = {
        "admin/nodes"=>{:stylesheets=>["controllers/admin/nodes"],
                                 :javascripts=>["controllers/admin/nodes"]},
        "admin/other_site/other_nodes"=>{:stylesheets=>["controllers/admin/other_site/other_nodes"],
                                 :javascripts=>["controllers/admin/other_site/other_nodes"]},
        "releaf/content/nodes"=>{:stylesheets=>["releaf/controllers/releaf/content/nodes"],
                                 :javascripts=>["releaf/controllers/releaf/content/nodes"]},
        "releaf/i18n_database/translations"=>{:stylesheets=>["releaf/controllers/releaf/i18n_database/translations"],
                                              :javascripts=>["releaf/controllers/releaf/i18n_database/translations"]},
        "releaf/permissions/sessions" => {:stylesheets=>["releaf/controllers/releaf/permissions/sessions"], :javascripts=>[]}
      }
      expect(described_class.noncompiled_assets).to eq(list)
    end
  end

  describe ".compiled_assets?" do
    context "when `Rails.application.assets` is not nil" do
      it "returns true" do
        allow(Rails.application).to receive(:assets).and_return(nil)
        expect(described_class.compiled_assets?).to be true
      end
    end

    context "when `Rails.application.assets` is nil" do
      it "returns false" do
        allow(Rails.application).to receive(:assets).and_return("x")
        expect(described_class.compiled_assets?).to be false
      end
    end
  end

  describe ".assets" do
    before do
      described_class.class_variable_set(:@@compiled_assets, nil)
      allow(described_class).to receive(:compiled_assets).and_return("a")
      allow(described_class).to receive(:noncompiled_assets).and_return("b")
    end

    context "when compiled assets is not available" do
      it "returns non compiled assets" do
        allow(described_class).to receive(:compiled_assets?).and_return(false)
        expect(described_class.assets).to eq("b")
      end
    end

    context "when compiled assets available" do
      before do
        allow(described_class).to receive(:compiled_assets?).and_return(true)
      end

      it "caches compiled assets list" do
        expect(described_class).to receive(:compiled_assets).once.and_return("a")
        described_class.assets
        described_class.assets
      end

      it "returns compiled assets" do
        expect(described_class.assets).to eq("a")
      end
    end
  end
end
