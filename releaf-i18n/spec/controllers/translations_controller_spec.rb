require 'spec_helper'

describe Releaf::TranslationsController do
  login_as_admin :admin

  before do
    @time_now = Time.parse("1981-02-23 21:00:00 UTC")
    Time.stub(:now).and_return(@time_now)
  end

  before build_translations: true do
    @t1 = FactoryGirl.create(:translation, key: 'test.key1')
    @t2 = FactoryGirl.create(:translation, key: 'great.stuff')
    @t3 = FactoryGirl.create(:translation, key: 'geek.stuff')

    @t1_en = FactoryGirl.create(:translation_data, lang: 'en', localization: 'testa atslēga', translation_id: @t1.id)

    @t2_en = FactoryGirl.create(:translation_data, lang: 'en', localization: 'awesome stuff', translation_id: @t2.id)
    @t2_lv = FactoryGirl.create(:translation_data, lang: 'lv', localization: 'lieliska manta', translation_id: @t2.id)

    @t3_en = FactoryGirl.create(:translation_data, lang: 'en', localization: 'geek stuff', translation_id: @t3.id)
    @t3_lv = FactoryGirl.create(:translation_data, lang: 'lv', localization: 'nūģu lieta', translation_id: @t3.id)
  end


  describe "GET #index", build_translations: true do
    context "when not searching" do
      it "renders all translations" do
        get :index
        expect( assigns(:collection) ).to have(3).item
      end
    end

    context "when searching" do
      it "searches by translation key" do
        get :index, search: 'great'
        expect( assigns(:collection) ).to have(1).item
      end

      it "searched by localized values" do
        get :index, search: 'manta'
        expect( assigns(:collection) ).to have(1).item
      end
    end
  end

  describe "GET #edit", build_translations: true do
    context "when search scope is not given" do
      it "renders all translations" do
        get :edit
        expect( assigns(:collection) ).to have(3).item
      end
    end

    context "when search scope is given" do
      it "renders translations matching search pattern" do
        get :index, search: 'stuff'
        expect( assigns(:collection) ).to have(2).item
      end
    end
  end

  describe "#update" do
    it "updates Settings.i18n_updated_at" do
      expect( Settings ).to receive(:i18n_updated_at=).and_call_original
      put :update, id: @resource, translations: [{key: 'a.b.c', localizations: {en: 'test', lv: 'xxl'}}]
      expect(Settings.i18n_updated_at).to eq("1981-02-23 21:00:00 UTC")
    end

    it "updates translations"
  end

  describe "#import" do
    it "needs test"
  end

  # describe "#import" do
  #   render_views

  #   it "returns uploaded excel data as json" do
  #     @resource = FactoryGirl.create(:translation_group)
  #     @request.env['CONTENT_TYPE'] = 'multipart/form-data'
  #     excel = Rack::Test::UploadedFile.new(File.dirname(__FILE__) + '/../fixtures/time.formats.xlsx', "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
  #     # fix nonexistent :tempfile in rack-test
  #     excel.stub(:tempfile) { excel }
  #     post :import, id: @resource, :resource => { import_file: excel }, :format => :json

  #     expect(JSON.parse(response.body)).to eq({"sheets"=>{"time.formats"=>{"default"=>{"en"=>"%Y.%m.%d %H:%M"}}}})
  #   end
  # end
end
