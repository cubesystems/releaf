module Releaf
  class ContentController < BaseController

    def fields_to_display
      return super unless view.to_sym == :show
      return %w[name parent_id visible protected content]
    end

    def build_secondary_panel_variables
      @nodes = Node.roots
      super
    end

    def index
      authorize! :index, Node
      respond_to do |format|
        format.html
      end
    end

    def create
      content_type = _node_params[:content_type].constantize
      authorize! :create, content_type
      @resource = current_object_class.new(_node_params)
      @resource.assign_attributes(_node_common_fields_params)

      respond_to do |format|
        if @resource.save
          format.html { redirect_to url_for(:action => "index", :controller => 'content')}
        else
          form_extras
          @order_nodes = Node.where(:parent_id => (params[:parent_id] ? params[:parent_id] : nil))
          format.html { render action: "new" }
        end
      end
    end

    def generate_url
      tmp_resource = nil

      if params[:id]
        tmp_resource = Node.find(params[:id])
      elsif params[:parent_id].blank? == false
        parent = Node.find(params[:parent_id])
        tmp_resource = parent.children.new
      else
        tmp_resource = Node.new
      end

      tmp_resource.name = params[:name]
      tmp_resource.slug = nil
      # FIXME calling private method
      tmp_resource.send(:ensure_unique_url)

      respond_to do |format|
        format.js { render :text => tmp_resource.slug }
      end
    end

    def update
      @resource = current_object_class.find(params[:id])
      authorize! :edit, @resource

      form_extras
      @order_nodes = Node.where(:parent_id => (@resource.parent_id ? @resource.parent_id : nil)).where('id != :id', :id => params[:id])

      @resource.assign_attributes(_node_params)
      @resource.assign_attributes(_node_common_fields_params)


      respond_to do |format|
        if @resource.save
          format.html { redirect_to url_for(:action => "edit") }
        else
          format.html { render action: "edit" }
        end
      end
    end

    def new
      authorize! :create, current_object_class
      unless params[:ajax] == '1'
        super
        @order_nodes = Node.where(:parent_id => (params[:parent_id] ? params[:parent_id] : nil))
        @position = 1
        @resource.parent_id = params[:parent_id]
        form_extras
      else
        Rails.application.eager_load!
        get_base_models
        render 'ajax.new', :layout => nil
      end
    end

    def edit
      super
      @order_nodes = Node.where(:parent_id => (@resource.parent_id ? @resource.parent_id : nil)).where('id != :id', :id => params[:id])

      if @resource.higher_item
        @position = @resource.higher_item.position
      else
        @position = 1
      end

      form_extras
    end

    def get_content_form
      Rails.application.eager_load!
      raise ArgumentError unless NodeBase.node_classes.map { |nc| nc.name }.include? params[:content_type]
      @node = current_object_class.find(params[:id])
      authorize! :edit, @resource

      @resource = params[:content_type].constantize.new

      respond_to do |format|
        format.html { render :partial => 'get_content_form', :layout => false }
      end

    end

    def current_object_class
      Node
    end

    protected

    def _node_common_fields_params
      allowed_params = (@resource.common_field_names).map { |f| f.sub(/_uid$/, '') }
      params.require(:resource).permit(*allowed_params)
    end

    def _node_params
      allowed_params = (%w[parent_id name content_type slug position data visible protected content_object_attributes]).map { |f| f.sub(/_uid$/, '') }
      params.require(:resource).permit(*allowed_params)
    end

    private

    def form_extras
      Rails.application.eager_load!
      get_base_models

      new_content_if_needed
    end

    def resource_params action=params[:action]
      # make sure none of actions, that are defined by BaseController can update resource
      []
    end

    def new_content_if_needed
      return if @resource.content
      @resource.content = @resource.content_type.constantize.new if get_base_models.map { |bm| bm.name }.include? @resource.content_type
    end

    def get_base_models
      @base_models ||= NodeBase.node_classes
    end

  end
end
