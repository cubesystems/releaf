module Releaf
  class ApplicationController < BaseController
    # I've no idea where this route to releaf/application.index comes from

    def index
      respond_to do |format|
        format.html { redirect_to url_for(:action => 'index', :controller => 'releaf/content') }
      end
    end
  end
end
