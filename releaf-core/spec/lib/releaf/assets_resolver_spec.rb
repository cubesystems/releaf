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

    context "when controller assets of given type (javascripts/stylesheets) exists" do
      it "returns array with controller specific asset alognside base assets" do
        allow(described_class).to receive(:assets).and_return(
          "controllers/releaf/i18n_database/translations.js" => "controllers/releaf/i18n_database/translations.js",
          "controllers/releaf/i18n_database/translations.css" => "controllers/releaf/i18n_database/translations.css",
        )
        expect(described_class.controller_assets("releaf/i18n_database/translations", :javascripts))
          .to eq(["a", "b", "controllers/releaf/i18n_database/translations.js"])

        expect(described_class.controller_assets("releaf/i18n_database/translations", :stylesheets))
          .to eq(["a", "b", "controllers/releaf/i18n_database/translations.css"])
      end
    end

    context "when no controller assets of given type (javascripts/stylesheets) exists" do
      it "returns only base assets" do
        allow(described_class).to receive(:assets).and_return(
          "controllers/releaf/i18n_database/translations.fonts" => "controllers/releaf/i18n_database/translations.fonts",
          "i18n_database/translations.css" => "i18n_database/translations.css",
        )
        expect(described_class.controller_assets("releaf/i18n_database/translations", :javascripts))
          .to eq(["a", "b"])

        expect(described_class.controller_assets("releaf/i18n_database/translations", :stylesheets))
          .to eq(["a", "b"])
      end
    end
  end

  describe ".compiled_assets" do
    it "returns array with uniq controller scoped stylesheets and javascripts" do
      allow(Rails.application.assets_manifest).to receive(:files).and_return(
        "controllers/releaf/content/nodes-72ac849dd467fe827933f15c45ea77a2b7beac55379147f3be4a21779787f484.js"=>{"logical_path"=>"controllers/releaf/content/nodes.js", "mtime"=>"2015-12-01T13:55:41+02:00", "size"=>1530, "digest"=>"72ac849dd467fe827933f15c45ea77a2b7beac55379147f3be4a21779787f484", "integrity"=>"sha256-cqyEndRn/oJ5M/FcRep3ore+rFU3kUfzvkohd5eH9IQ="},
        "controllers/releaf/content/nodes-2ac6b38702a01d9e0918adasasdasda45e746.css"=>{"logical_path"=>"controllers/releaf/content/nodes.css", "mtime"=>"2016-02-18T13:36:15+02:00", "size"=>4301, "digest"=>"2ac6b38702a01d9e0918adasasdasda45e746", "integrity"=>"sha256-asdasdasdsa+adasdasda="},
        # simulate old assets cache here
        "controllers/releaf/content/nodes-adsaassdkdasd.css"=>{"logical_path"=>"controllers/releaf/content/nodes.css", "mtime"=>"2016-02-18T13:36:15+02:00", "size"=>4301, "digest"=>"adsaassdkdasd", "integrity"=>"sha256-asdasdasdsa+adasdasda="},
        "releaontxzcent/nodes-asdassdasdsaasdasd.css"=>{"logical_path"=>"releaontxzcent/nodes-asdassdasdsaasdasd.css", "mtime"=>"2016-01-18T13:36:15+02:00", "size"=>5919, "digest"=>"asdassdasdsaasdasd", "integrity"=>"sha256-KsazhwKgHZ4JGPBY+SOznIMgzfph9Bx0lHUrZIpF50Y="},
        "controllers/releaf/permissions/sessions-9eb2f3275ea7578a6a95ca413d318a9984ef93c0d6645f11cf77fe82a2639cf0.css"=>{"logical_path"=>"controllers/releaf/permissions/sessions.css", "mtime"=>"2016-01-18T13:36:15+02:00", "size"=>2205, "digest"=>"9eb2f3275ea7578a6a95ca413d318a9984ef93c0d6645f11cf77fe82a2639cf0", "integrity"=>"sha256-nrLzJ16nV4pqlcpBPTGKmYTvk8DWZF8Rz3f+gqJjnPA="}
      )

      list = [
        "controllers/releaf/content/nodes.js",
        "controllers/releaf/content/nodes.css",
        "controllers/releaf/permissions/sessions.css"
      ]
      expect(described_class.compiled_assets).to eq(list)
    end
  end

  describe ".noncompiled_assets" do
    it "returns array with controller scoped stylesheets and javascripts" do
      list = [
        "controllers/admin/books.js",
        "controllers/admin/nodes.js",
        "controllers/admin/other_site/other_nodes.js",
        "controllers/admin/nodes.css",
        "controllers/admin/other_site/other_nodes.css",
        "controllers/releaf/content/nodes.js",
        "controllers/releaf/content/nodes.css",
        "controllers/releaf/permissions/sessions.css",
        "controllers/releaf/i18n_database/translations.js",
        "controllers/releaf/i18n_database/translations.css"
      ]
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
      allow(described_class).to receive(:assets_hash).with("a").and_return("aa")
      allow(described_class).to receive(:assets_hash).with("b").and_return("bb")
    end

    context "when compiled assets is not available" do
      it "returns grouped non compiled assets" do
        allow(described_class).to receive(:compiled_assets?).and_return(false)
        expect(described_class.assets).to eq("bb")
      end
    end

    context "when compiled assets available" do
      before do
        allow(described_class).to receive(:compiled_assets?).and_return(true)
      end

      it "caches grouped compiled assets list" do
        expect(described_class).to receive(:assets_hash).once.and_return("aa")
        described_class.assets
        described_class.assets
      end

      it "returns grouped compiled assets" do
        expect(described_class.assets).to eq("aa")
      end
    end
  end
end
