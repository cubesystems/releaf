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
      @collection = Node.roots
    end

    def generate_url
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
      super do
        new_common
      end

      render layout: nil if ajax?
    end

    def create
      super do
        new_common
      end
    end

    def copy_dialog
      @node = Node.find params[:id]
      @collection = Node.roots
      render layout: nil
    end

    def copy
      node = Node.find params[:id]
      copy_node(node, params[:new_parent_id], false)
    end

    def move_dialog
      @node = Node.find params[:id]
      @collection = Node.roots
      render layout: nil
    end

    def move
      node = Node.find params[:id]
      copy_node(node, params[:new_parent_id], true)
    end

    def go_to_dialog
      @collection = Node.roots
      render layout: nil
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
      Node
    end


    private

    def copy_node node, new_parent_id, delete_original = false
      return unless node.instance_of?(Releaf::Node)
      method_to_call = :copy_to_node
      method_to_call = :move_to_node if delete_original
      if node.send(method_to_call, new_parent_id).nil?
        flash[:error] = { id: :resource_status, message: I18n.t("#{method_to_call} not ok", scope: 'notices.' + controller_scope_name) }
      else
        flash[:success] = { id: :resource_status, message: I18n.t("#{method_to_call} ok", scope: 'notices.' + controller_scope_name) }
      end
      redirect_to :action => "index"
    end

    def edit_common
      @order_nodes = Node.where(parent_id: (@resource.parent_id ? @resource.parent_id : nil)).where('id != :id', id: params[:id])

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
        unless ActsAsNode.classes.include? params[:content_type]
          raise ArgumentError, "invalid content_type"
        end

        @order_nodes = Node.where(parent_id: (params[:parent_id] ? params[:parent_id] : nil))
        @item_position = 1

        @resource.content_type = params[:content_type]
        @resource.parent_id = params[:parent_id]

        content_class = params[:content_type].constantize
        if content_class < ActiveRecord::Base
          @resource.content = content_class.new
        end
      end
    end

    def content_type_class_names
      content_type_classes.map { |nc| nc.name }.sort
    end

    def content_type_classes
      ActsAsNode.classes.map{|class_name| class_name.constantize}
    end

    def resource_params
      super + [:content_attributes] + @resource.common_field_names
    end
  end
end
