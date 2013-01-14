class Admin::RolesController < Leaf::BaseController

  def columns( view = nil )
    if view == 'index'
      super(view) - ['permissions']
    else
      (super(view) - ['default']).insert(1, 'default')
    end
  end

  protected

  def role_params( action )
    return [] unless [:update, :create].include? action

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
