require 'spec_helper'

# use Admin::BooksController as it inherit Releaf::BaseController and
# have no extra methods or overrides
describe Releaf::AdminsController do
  before do
    sign_in FactoryGirl.create(:admin)
  end

  describe "GET #new" do
    it "assigns default role" do
      get :new
      expect(assigns(:resource).role).to eq(Releaf::Role.first)
    end
  end

  describe "GET #index" do
    before do
      FactoryGirl.create(:content_admin, name: "John")
      FactoryGirl.create(:content_admin, name: "Bill", surname: "Green", email: "another@example.com")
    end

    it "searches by name, surname and email" do
      get :index, search: "bill green another@example"
      expect(assigns(:collection).count).to eq(1)
    end
  end
end
