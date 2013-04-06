module Releaf
  class Role < ActiveRecord::Base
    self.table_name = 'releaf_roles'

    validates_presence_of :name
    validates_uniqueness_of :name, :case_sensitive => false

    has_many :admins

    before_save :update_permissions

    attr_accessible \
      :name,
      :default_controller

    alias_attribute :to_text, :name

    # Create *_permission getters, setters and attributes for all available admin controllers
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

    # Allow destroying of role if no Releaf::Admin object is using it
    def destroy
      if Releaf::Admin.where(:role_id => id).count == 0
        super
      end
    end

    # Return true/false access for given controller and action
    # @param [Controller, String] controller to check access
    # @param [Controller, String] action to check access
    # @return [Boolean] access to controller and action
    def authorize!(controller, action = nil)
      if controller.is_a? String
        controller_name = controller
      else
        controller_name = controller.class.to_s.gsub("::", "").gsub("Controller", "").gsub!(/(.)([A-Z])/,'\1_\2').downcase
      end

      return send(controller_name + "_permission")
    end

    protected

    # Parse stored YAML data
    def permissions
      perm = read_attribute :permissions
      return YAML::load(perm) if perm
      return []
    end

    # Store data as YAML
    def permissions=(perm=[])
      raise ArgumentError unless perm.is_a? Array
      new_perm = perm.clone
      new_perm.delete_if { |p| p.blank? }
      write_attribute :permissions, YAML::dump(new_perm)
    end

    private

    # Update permissions for all available admin controllers
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
