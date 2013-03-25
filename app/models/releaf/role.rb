module Releaf
  class Role < ActiveRecord::Base
    self.table_name = 'releaf_roles'

    validates_presence_of :name
    validates_uniqueness_of :name, :case_sensitive => false

    has_many :admins

    before_save :update_permissions
    after_save :update_default_role

    attr_accessible \
      :name,
      :default,
      :default_controller

    alias_attribute :to_text, :name

    Releaf.available_admin_controllers.each do |controller_name|
      perms = controller_name.gsub("/", "_")
      attr_accessible :"#{perms}_permission"
      define_method "#{perms}_permission=" do |p|
        return if p.nil?

        raise ArgumentError, "permission must be one of: true, false, '0', '1'" unless [true, false, '0', '1'].include? p
        self.instance_variable_set "@#{perms}_permission", (p == true || p == '1')
      end

      define_method "#{perms}_permission" do
        iv = self.instance_variable_get "@#{perms}_permission"
        return (iv == '1' || iv == true) unless iv.nil?
        permissions.include? perms
      end
      alias_method "#{perms}_permission?", "#{perms}_permission"
    end

    scope :order_by, lambda { |field=:name| order(field) }

    def self.default
      Role.find_by_default(true)
    end

    def default
      return true if @set_default
      self.default?
    end

    def default=(is_default=true)
      return unless is_default == true or is_default == '1'
      @set_default = true
    end

    def destroy
      if (self.default? == false) && (!self.permissions.include?('admin') || (self.permissions.include?('admin') && Role.admin_roles_count > 1))
        super
      end
    end

    def self.admin_roles_count
      Role.where('permissions LIKE "%\n- admin\n%"').count
    end

    def authorize!(controller, action = nil, raise_error = true)
      if controller.is_a? String
        controller_name = controller
      else
        controller_name = controller.class.to_s.gsub("::", "").gsub("Controller", "").gsub!(/(.)([A-Z])/,'\1_\2').downcase
      end

      if send(controller_name + "_permission")
        return true
      elsif raise_error
        raise Releaf::AccessDenied.new(controller_name, action)
      end
    end

    protected

    def permissions
      perm = read_attribute :permissions
      return YAML::load(perm) if perm
      return []
    end

    def permissions=(perm=[])
      raise ArgumentError unless perm.is_a? Array
      new_perm = perm.clone
      new_perm.delete_if { |p| p.blank? }
      write_attribute :permissions, YAML::dump(new_perm)
    end

    private

    def update_default_role
      if @set_default && self.id
        Role.update_all 'releaf_roles.default = false', ['releaf_roles.id <> ?', self.id]
        Role.update_all 'releaf_roles.default = true', ['releaf_roles.id = ?', self.id]
        @set_default = false
        self.reload
      end
    end

    def update_permissions
      my_permissions = []

      Releaf.available_admin_controllers.each do |controller_name|
        perms = controller_name.gsub("/", "_")
        p = perms if self.send(:"#{perms}_permission")
        my_permissions.push p if p.blank? == false
      end

      self.permissions = my_permissions
    end

  end
end
