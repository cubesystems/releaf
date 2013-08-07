require 'spec_helper'

# use Admin::BooksController as it inherit Releaf::BaseController and
# have no extra methods or overrides
describe Admin::BooksController do
  before do
    sign_in FactoryGirl.create(:admin)
    @breadcrumbs_base = [
      {"name" => I18n.t('home', :scope => 'admin.breadcrumbs'), "url" => releaf_root_path},
      {"name" => I18n.t('admin/books', :scope => "admin.menu_items"), "url" => admin_books_path},
    ]
  end

  describe "GET #new" do
    it "assigns the requested record to @resource" do
      get :new

      expect(assigns(:resource).new_record?).to be_true
    end

    describe "it assigns requested record breadcrumb part" do
      context "when object respond to #to_text method" do
        it "use #to_text return in resource breadcrumb name part" do
          get :new
          breadcrumbs = @breadcrumbs_base + [{"name" => "New record", "url" => new_admin_book_path}]

          expect(assigns(:breadcrumbs)).to eq(breadcrumbs)
        end
      end
    end
  end

  describe "GET #edit" do
    before do
      @resource = FactoryGirl.create(:book)
    end

    it "assigns the requested record to @resource" do
      get :edit, id: @resource

      expect(assigns(:resource)).to eq(@resource)
    end

    describe "it assigns requested record breadcrumb part" do
      context "when object respond to #to_text method" do
        it "use #to_text return in resource breadcrumb name part" do
          get :edit, id: @resource
          breadcrumbs = @breadcrumbs_base + [{"name" => @resource.to_text, "url" => edit_admin_book_path(@resource.id)}]

          expect(assigns(:breadcrumbs)).to eq(breadcrumbs)
        end
      end

      context "when object do not respond to #to_text method" do
        it "use default translation in resource breadcrumb name part" do
          pending "Find out way how to stub loaded resource #respond_to?(:to_text)"
          Book.any_instance.stub(:respond_to?).with(:to_text).and_return(false)
          get :edit, id: @resource
          breadcrumbs = @breadcrumbs_base + [{"name" => "Edit resource", "url" => edit_admin_book_path(@resource.id)}]

          expect(assigns(:breadcrumbs)).to eq(breadcrumbs)
        end
      end
    end
  end
end
