module Releaf
  class BaseController < ActionController::Base
    include Releaf::ControllerSupport

    def index
      prepare_index
      respond_with(@collection)
    end

    def new
      prepare_new
      respond_with(@resource)
    end

    def show
      if feature_available?(:show)
        prepare_show
      else
        redirect_to url_for(action: 'edit', id: params[:id])
      end
    end

    def edit
      prepare_edit
      respond_with(@resource)
    end

    def create
      prepare_create
      @resource.save
      respond_with(@resource, location: (success_url if @resource.persisted?), redirect: true)
    end

    def update
      prepare_update
      @resource.update_attributes(resource_params)
      respond_with(@resource, location: success_url)
    end

    def confirm_destroy
      prepare_destroy
      @restricted_relations = Releaf::ResourceUtilities.restricted_relations(@resource)
      respond_with(@resource, destroyable: destroyable?)
    end

    def toolbox
      prepare_toolbox
      respond_with(@resource)
    end

    def destroy
      prepare_destroy
      @resource.destroy if destroyable?
      respond_with(@resource, location: index_url)
    end

    def prepare_index
      # load resource only if they are not loaded yet
      @collection = resources unless collection_given?

      search(params[:search])

      unless resources_per_page.nil?
        @collection = @collection.page( params[:page] ).per_page( resources_per_page )
      end
    end

    def prepare_new
      # load resource only if is not initialized yet
      new_resource unless resource_given?
      add_resource_breadcrumb(@resource)
    end

    def prepare_create
      # load resource only if is not initialized yet
      new_resource unless resource_given?
      @resource.assign_attributes(resource_params)
    end

    def prepare_show
      prepare_resource_view
    end

    def prepare_edit
      prepare_resource_view
    end

    def prepare_resource_view
      # load resource only if is not loaded yet
      load_resource unless resource_given?
      add_resource_breadcrumb(@resource)
    end

    def prepare_update
      # load resource only if is not loaded yet
      load_resource unless resource_given?
    end

    def prepare_destroy
      load_resource
    end

    def prepare_toolbox
      load_resource
    end
  end

  ActiveSupport.run_load_hooks(:base_controller, self)
end
