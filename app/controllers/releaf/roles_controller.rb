module Releaf
  class RolesController < BaseController

    def resource_class
      Releaf::Role
    end

    def fields_to_display
      case params[:action].to_sym
      when :index
        %w[name admin_permission default]
      when :create, :edit, :new, :update, :show
        %w[name default permissions]
      else
        []
      end
    end

    protected

    def resource_params
      return [] unless %w[update create].include? params[:action]

      fields = ['name', 'default']
      AdminAbility::PERMISSIONS.each do |permission|
        if permission.is_a? String
          fields.push "#{permission}_permission"
        elsif permission.is_a? Array
          fields.push "#{permission[0]}_permissions"
        else
          raise RuntimeError, 'invalid permissions'
        end
      end
      return fields
    end

  end
end
