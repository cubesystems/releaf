require 'rails_helper'

describe Releaf::I18nDatabase::TranslationsController do
  def file_attachment
    test_document = File.expand_path('../../fixtures/translations_import.xlsx', __dir__)
    Rack::Test::UploadedFile.new(test_document)
  end

  login_as_user :user

  before do
    @time_now = Time.parse("1981-02-23 21:00:00 UTC")
    allow(Time).to receive(:now).and_return(@time_now)
  end

  before build_translations: true do
    @t1 = Releaf::I18nDatabase::I18nEntry.create(key: 'test.key1')
    @t2 = Releaf::I18nDatabase::I18nEntry.create(key: 'great.stuff')
    @t3 = Releaf::I18nDatabase::I18nEntry.create(key: 'geek.stuff')
    @t1.i18n_entry_translation.create(locale: 'en', text: 'testa atslēga')
    @t2.i18n_entry_translation.create(locale: 'en', text: 'awesome stuff')
    @t2.i18n_entry_translation.create(locale: 'lv', text: 'lieliska manta')
    @t3.i18n_entry_translation.create(locale: 'en', text: 'geek stuff')
    @t3.i18n_entry_translation.create(locale: 'lv', text: 'nūģu lieta')
  end

  describe "GET #index", build_translations: true do
    context "when not searching" do
      it "renders all translations" do
        get :index
        expect( assigns(:collection).size ).to eq(3)
      end
    end

    context "when searching" do
      it "searches by translation key" do
        get :index, search: 'great'
        expect( assigns(:collection).size ).to eq(1)
      end

      it "searched by localized values" do
        get :index, search: 'manta'
        expect( assigns(:collection).size ).to eq(1)
      end
    end

    context "when searching blank translations" do
      it "returns translations that has blank translation in any localization" do
        get :index, only_blank: 'true'
        expect( assigns(:collection).map(&:id) ).to match_array [@t1.id]
      end
    end
  end

  describe "GET #edit", build_translations: true do
    context "when search scope is not given" do
      it "renders all translations" do
        get :edit
        expect( assigns(:collection).size ).to eq(3)
      end
    end

    context "when search scope is given" do
      it "renders translations matching search pattern" do
        get :index, search: 'stuff'
        expect( assigns(:collection).size ).to eq(2)
      end
    end
  end

  describe "#update" do
    context "when save successful" do
      it "updates translations updated_at" do
        expect(Releaf::I18nDatabase::Backend).to receive("translations_updated_at=").with(@time_now)
        put :update, translations: [{key: 'a.b.c', localizations: {en: 'test', lv: 'xxl'}}]
      end

      context "when save with import" do
        before do
          put :update, translations: [{key: 'a.b.c', localizations: {en: 'test', lv: 'xxl'}}], import: "true"
        end

        it "redirects to index view" do
          expect(subject).to redirect_to(action: :index)
        end

        it "flash success notification with updated count" do
          expect(flash["success"]).to eq("id" => "resource_status", "message" => "successfuly imported 1 translations")
        end
      end

      context "when save without import" do
        before do
          put :update, translations: [{key: 'a.b.c', localizations: {en: 'test', lv: 'xxl'}}]
        end

        it "redirects to edit view" do
          expect(subject).to redirect_to(action: :edit)
        end

        it "flash success notification" do
          expect(flash["success"]).to eq("id" => "resource_status", "message" => "Update succeeded")
        end
      end
    end

    context "when save failed" do
      it "renders edit view" do
        put :update, translations: [{key: '', localizations: {en: 'test', lv: 'xxl'}}]
        expect(response).to render_template(:edit)
      end

      it "flash error notification" do
        put :update, translations: [{key: '', localizations: {en: 'test', lv: 'xxl'}}]
        expect(flash["error"]).to eq("id" => "resource_status", "message" => "Update failed")
      end
    end
  end

  describe "#import" do
    context "when file uploaded" do
      before do
        file = fixture_file_upload(File.expand_path('../../fixtures/translations_import.xlsx', __dir__),
                                   'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        post :import, import_file: file
      end

      it "parses uploaded file and assigns content to collection" do
        expect( assigns(:collection).size ).to eq(4)
      end

      it "assigns @import to true" do
        expect( assigns(:import) ).to be true
      end

      it "appends breadcrumb with 'import' part" do
        expect( assigns(:breadcrumbs).last ).to eq({name: "Import"})
      end
    end

    context "when no file uploaded" do
      it "redirects to index" do
        post :import
        expect(subject).to redirect_to(action: :index)
      end
    end
  end
end
