require 'spec_helper'

describe Releaf::BaseController do
  let(:new_resource){ Author.new }
  let(:resource){ create(:author) }
  class FooFormBuilder; end

  describe "#action_views"  do
    it "returns action > view translation hash" do
      hash = {
        new: :edit,
        update: :edit,
        create: :edit,
      }
      expect(subject.action_views).to eq(hash)
    end
  end

  describe "#action_view" do
    context "when given view does not exists within action views hash" do
      it "returns given action" do
        expect(subject.action_view("a")).to eq("a")
      end
    end

    context "when given view does not exists within action views hash" do
      it "returns given action" do
        expect(subject.action_view(:update)).to eq(:edit)
      end
    end

    it "lookup given action as symbol to within action views hash" do
      expect(subject.action_view("new")).to eq(:edit)
    end
  end

  describe "#active_view" do
    it "returns generic view name for current action" do
      allow(subject).to receive(:action_name).and_return("a")
      allow(subject).to receive(:action_view).with("a").and_return("b")
      expect(subject.active_view).to eq("b")
    end
  end

  describe "#form_url" do
    context "when given resource is new record" do
      it "returns url for create method" do
        allow(subject).to receive(:url_for).with(action: 'create', id: nil).and_return("/res/new")
        expect(subject.form_url(:edit, new_resource)).to eq("/res/new")
      end
    end

    context "when given resource is existing record" do
      it "returns url for update method" do
        allow(subject).to receive(:url_for).with(action: 'update', id: resource.id).and_return("/res/edit/")
        expect(subject.form_url(:edit, resource)).to eq("/res/edit/")
      end
    end
  end

  describe "#form_attributes" do
    it "returns basic releaf form attributes" do
      attributes = {
         multipart: true,
         class: "new-user",
         id: "new-user",
         data: {
           'validation-ok-handler' => 'ajax',
           'validation' => 'true'
         }
      }
      expect(subject.form_attributes(:edit, new_resource, :user)).to eq(attributes)
    end

    it "changes class/id depending whether given object is persisted" do
      expect(subject.form_attributes(:edit, new_resource, :user)[:id]).to eq("new-user")
      expect(subject.form_attributes(:edit, new_resource, :user)[:class]).to eq("new-user")

      expect(subject.form_attributes(:edit, resource, :user)[:id]).to eq("edit-user")
      expect(subject.form_attributes(:edit, resource, :user)[:class]).to eq("edit-user")
    end
  end

  describe "#form_builder_class" do
    it "returns resource class form builder" do
      allow(subject).to receive(:resource_class).and_return(Releaf::Permissions::User)
      allow(Releaf::Builder::Utility).to receive(:builder_class).with(Releaf::BaseController, Releaf::Permissions::User, :form).and_return("x")
      expect(subject.form_builder_class(:edit, new_resource)).to eq("x")
    end
  end

  describe "#table_builder_class" do
    it "returns resource class table builder" do
      allow(subject).to receive(:resource_class).and_return(Releaf::Permissions::User)
      allow(Releaf::Builder::Utility).to receive(:builder_class).with(Releaf::BaseController, Releaf::Permissions::User, :table).and_return("x")
      expect(subject.table_builder_class).to eq("x")
    end
  end

  describe "#table_options" do
    it "returns table options" do
      allow(subject).to receive(:table_builder_class).and_return("CustomTableBuilderClassHere")
      allow(subject).to receive(:feature_available?).with(:toolbox).and_return("boolean_value_here")

      options = {
        builder: "CustomTableBuilderClassHere",
        toolbox: "boolean_value_here"
      }
      expect(subject.table_options).to eq(options)
    end
  end

  describe "#form_options" do
    it "returns form options" do
      allow(subject).to receive(:form_builder_class).with(:delete, resource).and_return("CustomFormBuilderClassHere")
      allow(subject).to receive(:form_url).with(:delete, resource).and_return("/some-url-here")
      allow(subject).to receive(:form_attributes).with(:delete, resource, :author).and_return(some: "options_here")

      options = {
        builder: "CustomFormBuilderClassHere",
        as: :author,
        url: "/some-url-here",
        html: {some: "options_here"}
      }
      expect(subject.form_options(:delete, resource, :author)).to eq(options)
    end
  end
end

# use Admin::BooksController / Admin::AuthorsController as it inherit Releaf::BaseController and
# have no extra methods or overrides
describe Admin::AuthorsController do
  before do
    sign_in FactoryGirl.create(:user)
  end

  describe "#resource_edit_url" do
    let(:resource){ create(:author) }
    before do
      get :index
    end

    context "when edit feature available" do
      it "returns resource edit url with index_url within params" do
        url = "http://test.host/admin/authors/#{resource.id}/edit?index_url=%2Fadmin%2Fauthors"
        allow(subject).to receive(:feature_available?).with(:edit).and_return(true)
        expect(subject.resource_edit_url(resource)).to eq url
      end
    end

    context "when edit feature not available" do
      it "returns nil" do
        allow(subject).to receive(:feature_available?).with(:edit).and_return(false)
        expect(subject.resource_edit_url(Author.new)).to be nil
      end
    end
  end

  describe "#index_url" do
    context "when action is other than :index" do
      context "when params have 'index_url' defined" do
        it "returns params 'index_url'" do
          url = "/admin/something?a=1&b=2"
          get :new, index_url: url
          expect(subject.index_url).to eq(url)
        end
      end

      context "when does not have 'index_url' defined" do
        it "returns index action url" do
          get :new
          expect(subject.index_url).to eq("http://test.host/admin/authors")
        end
      end
    end

    context "when action is :index" do
      it "returns #current_url value" do
        get :index
        allow(subject).to receive(:current_url).and_return("random_string")
        expect(subject.index_url).to eq("random_string")
      end
    end
  end

  describe "#current_url" do
    it "returns current url without internal params" do
      get :index, ajax: 1, search: "something", page: 1
      expect(subject.current_url).to eq("/admin/authors?page=1&search=something")
    end
  end

  describe "GET index" do
    before do
      21.times do |i|
        FactoryGirl.create(:author)
      end
    end

    context "when @resources_per_page is nil" do
      it "assigns all resources to @collection" do
        get :index, show_all: 1
        expect(assigns(:collection).is_a?(ActiveRecord::Relation)).to be true
        expect(assigns(:collection).size).to eq(21)
      end
    end

    context "when @resources_per_page is not nil" do
      it "assigns maximum 20 resources to @collection" do
        get :index
        expect(assigns(:collection).is_a?(ActiveRecord::Relation)).to be true
        expect(assigns(:collection).size).to eq(20)
      end
    end
  end


  describe "DELETE #destroy" do
    before do
       @author = FactoryGirl.create(:author)
       FactoryGirl.create(:book, title: "The book", author: @author)
       FactoryGirl.create(:book, title: "Almost the book", author: @author)
    end

    it "creates flash error with message" do
      delete :destroy, id: @author
      expect(flash["error"]).to eq({"id" => "resource_status", "message" => "Cant destroy, because relations exists"})
    end
  end
end


describe Admin::BooksController do
  before do
    sign_in FactoryGirl.create(:user)
    @breadcrumbs_base = [
      {name: I18n.t('home', scope: 'admin.breadcrumbs'), url: releaf_root_path},
      {name: I18n.t('admin/books', scope: "admin.menu_items"), url: admin_books_path},
    ]
  end

  describe "GET #index" do
    before do
      FactoryGirl.create(:book, title: "great one")
      FactoryGirl.create(:book, title: "bad one")
      FactoryGirl.create(:book, title: "average third")
    end

    context "when empty search string given" do
      it "shows all records" do
        get :index, search: ""
        expect(assigns(:collection).count).to eq(3)
      end
    end

    context "when search string with multiple words given" do
      it "searches by given string" do
        get :index, search: "one grea"
        expect(assigns(:collection).count).to eq(1)
      end
    end

    context "when search string given" do
      it "searches by given string" do
        get :index, search: "great"
        expect(assigns(:collection).count).to eq(1)
      end
    end

    context "when no search given" do
      it "shows all records" do
        get :index
        expect(assigns(:collection).count).to eq(3)
      end
    end
  end

  describe "GET #new" do
    it "assigns the requested record to @resource" do
      get :new

      expect(assigns(:resource).new_record?).to be true
    end

    context "when the requested record responds to #to_text" do
      it "uses the result of #to_text for resource's breadcrumb name" do
        get :new
        breadcrumbs = @breadcrumbs_base + [{name: "New record", url: new_admin_book_path}]

        expect(assigns(:breadcrumbs)).to eq(breadcrumbs)
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

    context "when the requested record responds to #to_text" do
      it "uses the result of #to_text for resource's breadcrumb name" do
        get :edit, id: @resource
        breadcrumbs = @breadcrumbs_base + [{name: @resource.to_text, url: edit_admin_book_path(@resource.id)}]

        expect(assigns(:breadcrumbs)).to eq(breadcrumbs)
      end
    end

    context "when the requested record does not respond to #to_text" do
      it "uses default translation for resource's breadcrumb name" do
        skip "Find out way how to stub loaded resource #respond_to?(:to_text)"
        allow_any_instance_of(Book).to receive(:respond_to?).with(:to_text).and_return(false)
        get :edit, id: @resource
        breadcrumbs = @breadcrumbs_base + [{name: "Edit resource", url: edit_admin_book_path(@resource.id)}]

        expect(assigns(:breadcrumbs)).to eq(breadcrumbs)
      end
    end
  end
end
