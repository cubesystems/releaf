module Releaf
  class ContentController < BaseController
    helper_method :content_fields_to_display

    def content_fields_to_display obj_class
      if obj_class.respond_to? :releaf_fields_to_display
        obj_class.releaf_fields_to_display params[:action]
      else
        obj_class.column_names - %w[id created_at updated_at item_position]
      end
    end

    def fields_to_display
      return super unless params[:action] == 'show'
      return %w[name parent_id visible protected content]
    end

    def index
      @resources = Node.roots
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
        format.js { render text: tmp_resource.slug }
      end
    end

    def new
      @resource = resource_class.new
      @resource.parent_id = params[:parent_id]
      super

      if params[:content_type].blank?
        Rails.application.eager_load!
        @base_models = content_type_classes
      end

      @order_nodes = Node.where(parent_id: (params[:parent_id] ? params[:parent_id] : nil))
      @item_position = 1
      @resource.parent_id = params[:parent_id]

      if params[:content_type]
        content_class = params[:content_type].constantize
        if content_class <  Releaf::NodeBase
          @resource.content_type = params[:content_type]
          if content_class.node_type == 'Releaf::NodeBase'
            @resource.content = content_class.new
          end
        end
      end

      respond_to do |format|
        format.html do
          render layout: nil if params.has_key?(:ajax)
        end
      end
    end

    def edit
      super
      @order_nodes = Node.where(parent_id: (@resource.parent_id ? @resource.parent_id : nil)).where('id != :id', id: params[:id])

      if @resource.higher_item
        @item_position = @resource.item_position
      else
        @item_position = 1
      end
    end

    def get_content_form
      Rails.application.eager_load!
      raise ArgumentError unless content_type_class_names.include? params[:content_type]
      @node = resource_class.find(params[:id])

      @resource = params[:content_type].constantize.new

      respond_to do |format|
        format.html { render partial: 'get_content_form', layout: false }
      end
    end

    # override base_controller method for adding content tree ancestors
    # to breadcrumbs
    def add_resource_breadcrumb resource
      ancestors = []
      if resource.new_record?
        if resource.parent_id
          ancestors = resource.parent.ancestors
          ancestors += [resource.parent]
        end
      else
        ancestors = resource.ancestors
      end

      ancestors.each do |ancestor|
        @breadcrumbs << { name: ancestor, url: url_for( action: :edit, id: ancestor.id ) }
      end

      super resource
    end

    def resource_class
      Node
    end

    private

    def content_type_class_names
      content_type_classes.map { |nc| nc.name }.sort
    end

    def content_type_classes
      NodeBase.node_classes + BlankNodeBase.node_classes
    end

    def resource_params
      super + [:content_attributes]
    end
  end
end
