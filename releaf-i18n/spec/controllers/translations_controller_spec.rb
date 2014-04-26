require 'spec_helper'

describe Releaf::TranslationsController do
  login_as_admin :admin

  before do
    @time_now = Time.parse("1981-02-23 21:00:00 UTC")
    Time.stub(:now).and_return(@time_now)
  end

  describe "GET #index" do
    before do
      FactoryGirl.create(:translation_group, scope: 'fest')
      group = FactoryGirl.create(:translation_group, scope: 'test')
      FactoryGirl.create(:translation, translation_group: group, key: 'test.save')
    end

    it "searches by translation group scope and translations key" do
      get :index, search: "test save"
      expect(assigns(:collection).total_entries).to eq(1)
    end
  end

  describe "#create" do
    it "updates Settings.i18n_updated_at" do
      post :create, resource: FactoryGirl.attributes_for(:translation_group)
      expect(Settings.i18n_updated_at).to eq("1981-02-23 21:00:00 UTC")
    end
  end

  describe "#update" do
    it "updates Settings.i18n_updated_at" do
      @resource = FactoryGirl.create(:translation_group)
      put :update, id: @resource, resource: FactoryGirl.attributes_for(:translation_group)
      expect(Settings.i18n_updated_at).to eq("1981-02-23 21:00:00 UTC")
    end
  end

  describe "#destroy" do
    it "updates Settings.i18n_updated_at" do
      @resource = FactoryGirl.create(:translation_group)
      delete :destroy, id: @resource
      expect(Settings.i18n_updated_at).to eq("1981-02-23 21:00:00 UTC")
    end
  end

  describe "#import" do
    render_views

    it "returns uploaded excel data as json" do
      @resource = FactoryGirl.create(:translation_group)
      @request.env['CONTENT_TYPE'] = 'multipart/form-data'
      excel = Rack::Test::UploadedFile.new(File.dirname(__FILE__) + '/../fixtures/time.formats.xlsx', "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
      # fix nonexistent :tempfile in rack-test
      excel.stub(:tempfile) { excel }
      post :import, id: @resource, :resource => { import_file: excel }, :format => :json

      expect(JSON.parse(response.body)).to eq({"sheets"=>{"time.formats"=>{"default"=>{"en"=>"%Y.%m.%d %H:%M"}}}})
    end
  end
end
