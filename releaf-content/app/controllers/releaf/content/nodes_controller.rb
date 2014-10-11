module Releaf::Content
  class NodesController < Releaf::BaseController
    include Releaf::Attachments

    before_render :edit_common, only: [:edit, :update]
    before_filter :new_common, only: [:new, :create]

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

    def copy_dialog
      copy_move_dialog_common
    end

    def move_dialog
      copy_move_dialog_common
    end

    def copy
      copy_move_common do |resource|
        resource.copy_to_node! params[:new_parent_id]
      end
    end

    def move
      copy_move_common do |resource|
        resource.move_to_node! params[:new_parent_id]
      end
    end

    def go_to_dialog
      @collection = resource_class.roots

      respond_to do |format|
        format.html do
          render layout: nil
        end
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

    protected

    def prepare_index
      @collection = resource_class.roots
    end

    private

    def copy_move_common &block
      @resource = resource_class.find(params[:id])

      if params[:new_parent_id].nil?
        @resource.errors.add(:base, 'parent not selected')
        respond_after_copy_move false, @resource
      else
        begin
          @resource = yield(@resource)
        rescue ActiveRecord::RecordInvalid => e
          respond_after_copy_move false, e.record
        else
          resource_class.updated
          render_notification true
          respond_after_copy_move true, @resource
        end
      end
    end

    def respond_after_copy_move result, resource
      respond_to do |format|
        format.json do
          if result
            render json: {url: url_for( action: :index ), message: flash[:success][:message]}, status: 303
          else
            render json: Releaf::ErrorFormatter.format_errors(resource), status: 422
          end
        end

        format.html do
          render_notification false unless result
          redirect_to url_for( action: :index )
        end
      end
    end

    def copy_move_dialog_common
      @node = resource_class.find params[:id]
      @collection = resource_class.roots
    end

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

    def edit_common
      @order_nodes = resource_class.where(parent_id: @resource.parent_id).where('id <> :id', id: params[:id])

      if @resource.higher_item
        @item_position = @resource.item_position
      else
        @item_position = 1
      end
    end

    def new_common
      @resource = resource_class.new

      if params[:content_type].blank?
        load_content_types
      else
        @order_nodes = resource_class.where(parent_id: params[:parent_id])
        prepare_node
      end
    end

    def prepare_node
      @resource.content_type = node_content_class.name
      @resource.parent_id = params[:parent_id]
      @resource.item_position ||= resource_class.children_max_item_position(@resource.parent) + 1

      if node_content_class < ActiveRecord::Base
        @resource.build_content({})
        @resource.content_id_will_change!
      end
    end

    def load_content_types
      @content_types = resource_class.valid_node_content_classes(params[:parent_id]).sort do |a, b|
        I18n.t(a.name.underscore, scope: 'admin.content_types') <=> I18n.t(b.name.underscore, scope: 'admin.content_types')
      end
    end

    # Returns valid content type class
    def node_content_class
      unless ActsAsNode.classes.include? params[:content_type]
        raise ArgumentError, "invalid content_type"
      end

      params[:content_type].constantize
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
