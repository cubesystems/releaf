require 'spec_helper'

describe Admin::BooksController do
  describe "#current_params" do
    it "returns all but action, controller and format params" do
      get :index, :test => 'true'
      expect(controller.params).to include(:controller => 'admin/books', :action => 'index', :test => 'true')
      expect(controller.current_params).to include(:test => 'true')
      expect(controller.current_params).to_not include(:controller => 'admin/books', :action => 'index')
      expect(controller.current_params.keys).to have(1).key
    end
  end
end

describe Admin::AuthorsController do
  describe "#current_params" do
    it "returns all but action, controller and format params" do
      get :index, :test => 'true', :format => :json
      expect(controller.params).to include(:controller => 'admin/authors', :action => 'index', :test => 'true', :format => 'json')
      expect(controller.current_params).to include(:test => 'true')
      expect(controller.current_params).to_not include(:controller => 'admin/authors', :action => 'index', :format => 'json')
      expect(controller.current_params.keys).to have(1).key
    end
  end
end
