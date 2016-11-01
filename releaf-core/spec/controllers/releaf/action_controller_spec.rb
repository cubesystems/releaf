require 'rails_helper'

describe Releaf::ActionController do
  let(:new_resource){ Author.new }
  let(:resource){ create(:author) }
  let(:subject){ DummyController.new }

  module DummyControllerModule; end;

  class DummyController < Releaf::ActionController
    include DummyControllerModule
    def resource_class
      Author
    end
  end

  class Dummy::ChildDummyController < DummyController; end;
  class Dummy::GrandChildDummyController < Dummy::ChildDummyController; end;

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

  describe "#page_title" do
    before do
      allow(Rails.application.class).to receive(:parent_name).and_return("DummyApp")
    end

    context "when controller definition exists" do
      it "returns localized controller name from definitioned followed by application name" do
        definition = Releaf::ControllerDefinition.new("xx")
        allow(definition).to receive(:localized_name).and_return("Books")
        allow(subject).to receive(:definition).and_return(definition)
        expect(subject.page_title).to eq("Books - DummyApp")
      end
    end

    context "when controller definition does not exist" do
      it "returns only application name" do
        allow(subject).to receive(:definition).and_return(nil)
        expect(subject.page_title).to eq("DummyApp")
      end
    end
  end

  describe "#builder_class" do
    it "returns controller class scoped builder for given builder type" do
      allow(subject).to receive(:builder_scopes).and_return(["a", "b"])
      allow(Releaf::Builders).to receive(:builder_class).with(["a", "b"], :form).and_return("x")
      expect(subject.builder_class(:form)).to eq("x")
    end
  end

  describe "#short_name" do
    it "returns undercored class name with  Controller suffix removed" do
      allow(subject).to receive(:class).and_return(Admin::BooksController)
      expect(subject.short_name).to eq("admin/books")
    end
  end

  describe "#definition" do
    it "returns controller definition for controller short name" do
      allow(Releaf::ControllerDefinition).to receive(:for).with("xxx").and_return("yyy")
      allow(subject).to receive(:short_name).and_return("xxx")
      expect(subject.definition).to eq("yyy")
    end
  end

  describe "#builder_scopes" do
    context "when controller is a direct child of Releaf::ActionController" do
      it "returns an array with own and application builder scopes" do
        allow(subject).to receive(:application_scope).and_return("xxx")
        expect(subject.builder_scopes).to eq(["Dummy", "xxx"])
      end
    end

    it "excludes nil values from returned array" do
      allow(subject).to receive(:application_scope).and_return(nil)
      expect(subject.builder_scopes).to eq(["Dummy"])
    end

    context "when controller is a deeper descendant of Releaf::ActionController" do
      let(:subject) { Dummy::GrandChildDummyController.new }
      it "includes ancestor scopes up to but not including Releaf::ActionController" do
        allow(subject).to receive(:application_scope).and_return("xxx")
        expect(subject.class).to receive(:ancestor_controllers).and_call_original
        expect(subject.builder_scopes).to eq(["Dummy::GrandChildDummy", "Dummy::ChildDummy", "Dummy", "xxx"])
      end
    end
  end

  describe ".own_builder_scope" do
    it "returns controller class name without 'Controller'" do
      expect(DummyController.own_builder_scope).to eq "Dummy"
    end
  end

  describe ".ancestor_controllers" do
    it "return all ancestor controllers up to but not including Releaf::ActionController" do
      expect(DummyController.ancestor_controllers).to eq []
      expect(Dummy::GrandChildDummyController.ancestor_controllers).to eq([Dummy::ChildDummyController, DummyController])
    end
  end

  describe ".ancestor_builder_scopes" do
    it "return builder scopes for all ancestor controllers" do
      allow(Dummy::ChildDummyController).to receive(:own_builder_scope).and_call_original
      allow(DummyController).to receive(:own_builder_scope).and_call_original

      expect(Dummy::GrandChildDummyController.ancestor_builder_scopes).to eq(['Dummy::ChildDummy', 'Dummy'])
    end
  end

  describe "#application_scope" do
    it "returns node builder scope within releaf mount location scope" do
      allow(Releaf::Builders).to receive(:constant_defined_at_scope?).and_call_original
      allow(Releaf.application.config).to receive(:mount_location).and_return("admin")

      allow(Releaf::Builders).to receive(:constant_defined_at_scope?)
        .with("Admin", Object).and_return(true)
      expect(subject.application_scope).to eq("Admin")

      allow(Releaf::Builders).to receive(:constant_defined_at_scope?)
        .with("Admin", Object).and_return(false)
      expect(subject.application_scope).to eq(nil)

      allow(Releaf.application.config).to receive(:mount_location).and_return("")
      expect(subject.application_scope).to eq(nil)
    end
  end
end

# use Admin::BooksController / Admin::AuthorsController as it inherit Releaf::ActionController and
# have no extra methods or overrides
describe Admin::AuthorsController do
  before do
    sign_in FactoryGirl.create(:user)
  end

  describe "#index_path" do
    context "when action is other than :index" do
      context "when params have valid `index_path` value" do
        it "returns params 'index_path'" do
          get :new, index_path: "xxxxxxxx"
          allow(subject).to receive(:valid_index_path?).with("xxxxxxxx").and_return(true)
          expect(subject.index_path).to eq("xxxxxxxx")
        end
      end

      context "when params have invalid `index_path` value" do
        it "returns index action path" do
          get :new, index_path: "xxxxxxxx"
          allow(subject).to receive(:valid_index_path?).with("xxxxxxxx").and_return(false)
          expect(subject.index_path).to eq("/admin/authors")
        end
      end
    end

    context "when action is :index" do
      it "returns #current_path value" do
        get :index
        allow(subject).to receive(:current_path).and_return("random_string")
        expect(subject.index_path).to eq("random_string")
      end
    end
  end

  describe "#valid_index_path?" do
    context "when given value is string that starts with `/`" do
      it "returns true" do
        expect(subject.valid_index_path?("/admin/something?a=1&b=2")).to be true
      end
    end

    context "when given value is string that starts with other char than `/`" do
      it "returns false" do
        expect(subject.valid_index_path?("http:///admin/something?a=1&b=2")).to be false
      end
    end

    context "when given value is not string" do
      it "returns false" do
        expect(subject.valid_index_path?(123)).to be false
      end
    end

    context "when given value is blank" do
      it "returns false" do
        expect(subject.valid_index_path?(nil)).to be false
      end
    end
  end

  describe "#current_path" do
    it "returns current url without `ajax` param" do
      get :index, ajax: 1, search: "something", page: 1
      expect(subject.current_path).to eq("/admin/authors?page=1&search=something")
    end

    context "when no query parameters exists" do
      it "returns only request path" do
        get :index
        expect(subject.current_path).to eq("/admin/authors")
      end
    end

    it "caches current url value" do
      get :index
      expect(subject).to receive(:request).twice.and_call_original
      subject.current_path
      subject.current_path
      subject.current_path
      subject.current_path
    end
  end

  describe "#ajax?" do
    it "returns @_ajax instance variable value" do
      subject.instance_variable_set("@_ajax", "ll")
      expect(subject.ajax?).to eq("ll")
    end

    context "when @_ajax instance variable has not been set" do
      it "returns false" do
        expect(subject.ajax?).to be false
      end
    end
  end

  describe "#manage_ajax" do
    context "when `ajax` params does not exists within params" do
      it "assigns `false` to @_ajax instance variable" do
        expect{ get :index }.to change{ subject.instance_variable_get("@_ajax") }.from(nil).to(false)
      end
    end

    context "when `ajax` params exists within params" do
      it "assigns `true` to @_ajax instance variable" do
        expect{ get :index, ajax: 1 }.to change{ subject.instance_variable_get("@_ajax") }.from(nil).to(true)
      end

      it "removes ajax from `params`" do
        expect{ get :index, ajax: 1 }.to_not change{ subject.params[:ajax] }.from(nil)
      end

      it "removes ajax from `request.query_parameters`" do
        expect{ get :index, ajax: 1 }.to_not change{ subject.request.query_parameters[:ajax] }.from(nil)
      end
    end
  end

  describe "GET show" do
    let(:author){ create(:author) }

    context "when show feature is available" do
      it "assigns all resources to @collection" do
        allow(subject).to receive(:feature_available?).with(:show).and_return(true)
        get :show, id: author
        expect(assigns(:resource)).to eq(author)
      end
    end

    context "when show feature is not available" do
      it "does assign resource" do
        allow(subject).to receive(:feature_available?).and_call_original
        allow(subject).to receive(:feature_available?).with(:show).and_return(false)
        get :show, id: author
        expect(assigns(:resource)).to be nil
      end
    end
  end

  describe "GET index" do
    before do
      21.times do |i|
        FactoryGirl.create(:author)
      end
    end

    context "when resources_per_page is nil" do
      it "assigns all resources to @collection" do
        get :index, show_all: 1
        expect(assigns(:collection).is_a?(ActiveRecord::Relation)).to be true
        expect(assigns(:collection).size).to eq(21)
      end
    end

    context "when resources_per_page is not nil" do
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
      {name: I18n.t('admin/books'), url: admin_books_path}
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

    it "assigns special breadcrumb part for new record" do
      get :new
      breadcrumbs = @breadcrumbs_base + [{name: "New record", url: new_admin_book_path}]

      expect(assigns(:breadcrumbs)).to eq(breadcrumbs)
    end
  end

  describe "GET #edit" do
    before do
      @resource = create(:book)
    end

    it "assigns the requested record to @resource" do
      get :edit, id: @resource

      expect(assigns(:resource)).to eq(@resource)
    end

    it "assigns breadcrumb for resource" do
      allow(Releaf::ResourceBase).to receive(:title).with(@resource).and_return("xxx")
      get :edit, id: @resource
      breadcrumbs = @breadcrumbs_base + [{name: "xxx", url: edit_admin_book_path(@resource.id)}]

      expect(assigns(:breadcrumbs)).to eq(breadcrumbs)
    end
  end
end
