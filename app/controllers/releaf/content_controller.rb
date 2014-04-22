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
      return %w[name parent_id active protected content]
    end

    def index
      @collection = resource_class.roots
    end

    def generate_url
      tmp_resource = prepare_resource

      tmp_resource.name = params[:name]
      tmp_resource.slug = nil
      # FIXME calling private method
      tmp_resource.send(:ensure_unique_url)

      respond_to do |format|
        format.js { render text: tmp_resource.slug }
      end
    end

    def new
      super do
        new_common
      end

      render layout: nil if ajax?
    end

    def copy_dialog
      @node = resource_class.find params[:id]
      @collection = resource_class.roots
      render layout: nil
    end

    def copy
      copy_node(resource_class.find(params[:id]), params[:new_parent_id], false)
    end

    def move_dialog
      @node = resource_class.find params[:id]
      @collection = resource_class.roots
      render layout: nil
    end

    def move
      copy_node(resource_class.find(params[:id]), params[:new_parent_id], true)
    end

    def go_to_dialog
      @collection = resource_class.roots
      render layout: nil
    end

    # Override base controller create method
    # so we can assign content_type before further
    # processing
    def create
      @resource = resource_class.new
      @resource.content_type = node_content_type.name
      super do
        new_common
      end
    end

    def edit
      super do
        edit_common
      end
    end

    def update
      super do
        edit_common
      end
    end

    def get_content_form
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

    def self.resource_class
      # TODO class name should be configurable
      ::Node
    end

    private

    def prepare_resource
      if params[:id]
        return resource_class.find(params[:id])
      elsif params[:parent_id].blank? == false
        parent = resource_class.find(params[:parent_id])
        return parent.children.new
      else
        return resource_class.new
      end
    end

    def copy_node node, new_parent_id, delete_original = false
      return unless node.instance_of?(resource_class)
      method_to_call = :copy_to_node
      method_to_call = :move_to_node if delete_original
      if node.send(method_to_call, new_parent_id).nil?
        flash[:error] = { id: :resource_status, message: I18n.t("#{method_to_call} not ok", scope: notice_scope_name) }
      else
        flash[:success] = { id: :resource_status, message: I18n.t("#{method_to_call} ok", scope: notice_scope_name) }
      end
      redirect_to :action => "index"
    end

    def edit_common
      @order_nodes = resource_class.where(parent_id: (@resource.parent_id ? @resource.parent_id : nil)).where('id != :id', id: params[:id])

      if @resource.higher_item
        @item_position = @resource.item_position
      else
        @item_position = 1
      end
    end

    def new_common
      if params[:content_type].blank?
        @content_types = content_type_classes
      else
        @order_nodes = resource_class.where(parent_id: (params[:parent_id] ? params[:parent_id] : nil))
        @item_position = 1

        @resource.content_type = node_content_type.to_s
        @resource.parent_id = params[:parent_id]

        if node_content_type < ActiveRecord::Base
          @resource.content = node_content_type.new
        end
      end
    end

    # Returns valid content type class
    def node_content_type
      unless ActsAsNode.classes.include? params[:content_type]
        raise ArgumentError, "invalid content_type"
      end

      params[:content_type].constantize
    end

    def content_type_class_names
      content_type_classes.map { |nc| nc.name }.sort
    end

    def content_type_classes
      ActsAsNode.classes.map{|class_name| class_name.constantize}
    end

    def resource_params
      res_params = super
      res_params += [{content_attributes: permitted_content_attributes}]
      res_params -= %w[content_type]
      return res_params
    end

    def permitted_content_attributes
      @resource.content_class.acts_as_node_configuration[:permit_attributes]
    end
  end
end
