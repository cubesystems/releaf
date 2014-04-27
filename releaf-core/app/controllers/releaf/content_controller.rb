module Releaf
  class ContentController < BaseController

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
      new_common
      super

      respond_to do |format|
        format.html do
          render layout: nil if ajax?
        end
      end
    end

    def copy_dialog
      @node = resource_class.find params[:id]
      @collection = resource_class.roots

      respond_to do |format|
        format.html do
          render layout: nil
        end
      end
    end

    def copy
      copy_node(resource_class.find(params[:id]), params[:new_parent_id], false)
    end

    def move_dialog
      @node = resource_class.find params[:id]
      @collection = resource_class.roots

      respond_to do |format|
        format.html do
          render layout: nil
        end
      end
    end

    def move
      copy_node(resource_class.find(params[:id]), params[:new_parent_id], true)
    end

    def go_to_dialog
      @collection = resource_class.roots

      respond_to do |format|
        format.html do
          render layout: nil
        end
      end
    end

    # Override base controller create method
    # so we can assign content_type before further
    # processing
    def create
      new_common
      super
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
      @order_nodes = resource_class.where(parent_id: @resource.parent_id).where('id != :id', id: params[:id])

      if @resource.higher_item
        @item_position = @resource.item_position
      else
        @item_position = 1
      end
    end

    def new_common
      @resource = resource_class.new do |node|
        if params[:content_type].blank?
          @content_types = content_type_classes
        else
          @order_nodes = resource_class.where(parent_id: params[:parent_id])
          node.item_position ||= @order_nodes.to_a.inject(0) { |max, node| node.item_position + 1 > max ? node.item_position + 1 : max }

          node.content_type = node_content_class.name
          node.parent_id = params[:parent_id]

          if node_content_class < ActiveRecord::Base
            node.build_content({})
            node.content_id_will_change!
          end
        end
      end
    end

    # Returns valid content type class
    def node_content_class
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
