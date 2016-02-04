require 'rails_helper'

# use Admin::BooksController as it inherit Releaf::ActionController and
# have no extra methods or overrides
describe Releaf::Permissions::UsersController do
  before do
    sign_in FactoryGirl.create(:user)
  end

  describe "GET #new" do
    it "assigns default role" do
      get :new
      expect(assigns(:resource).role).to eq(Releaf::Permissions::Role.first)
    end
  end

  describe "GET #index" do
    before do
      FactoryGirl.create(:content_user, name: "John")
      FactoryGirl.create(:content_user, name: "Bill", surname: "Green", email: "another@example.com")
    end

    it "searches by name, surname and email" do
      get :index, search: "bill green another@example"
      expect(assigns(:collection).count).to eq(1)
    end
  end
end
