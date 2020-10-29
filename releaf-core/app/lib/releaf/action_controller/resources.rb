module Releaf::ActionController::Resources
  extend ActiveSupport::Concern

  included do
    helper_method :resource_class,

    # Tries to return resource class.
    #
    # If it fails to return proper resource class for your controller, or your
    # controllers name has no relation to resource class name, then simply
    # override this method to return class that you want.
    #
    # @return class
    def self.resource_class
      self.name.split('::', 2).last.sub(/Controller$/, '').classify.constantize
    end
  end

  def resource_params
    required_params.permit(*permitted_params)
  end

  # It sets various instance variables, that are later used in views and # controllers
  def resources_per_page
    40
  end

  # Returns which resource attributes can be updated with mass assignment.
  #
  # The resulting array will be passed to strong_parameters ``permit``
  def permitted_params
    Releaf::ResourceParams.new(resource_class).values
  end

  def new_resource
    @resource = resource_class.new
  end

  def load_resource
    begin
      @resource = resource_class.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      raise Releaf::RecordNotFound
    end
  end

  # Returns true if @resource is assigned (even if it's nil)
  def resource_given?
    !!defined? @resource
  end

  # Return ActiveRecord::Relation used in index
  #
  # @return ActiveRecord::Relation
  def resources
    resource_class.all
  end

  # @return class
  def resource_class
    @resource_class ||= self.class.resource_class
  end
end
