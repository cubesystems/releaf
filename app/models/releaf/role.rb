module Releaf
  class Role < ActiveRecord::Base
    self.table_name = 'releaf_roles'

    validates_presence_of :name
    validates_uniqueness_of :name, :case_sensitive => false

    has_many :admins

    before_save :update_permissions
    after_save :update_default_role

    alias_attribute :to_text, :name

    ::AdminAbility::PERMISSIONS.each do |perms|
      if perms.is_a? Array
        # attr_accessible :"#{perms[0]}_permissions"
        define_method :"#{perms[0]}_permissions=" do |p|
          return if p.nil?
          raise ArgumentError, "permission must be one of: #{perms[1].join(', ')}" unless perms[1].include? p.to_s
          self.instance_variable_set "@#{perms[0]}_permissions", p.to_s
        end

        define_method "#{perms[0]}_permissions" do
          iv = self.instance_variable_get "@#{perms[0]}_permissions"
          return iv unless iv.nil?
          perms[1].each do |perm|
            xperm = [perms[0], perm].join('__')
            return perm if permissions.include? xperm
          end
          return perms[1].first
        end

      elsif perms.is_a? String
        # attr_accessible :"#{perms}_permission"
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
      end
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
      AdminAbility::PERMISSIONS.each do |perms|
        p = nil
        if perms.is_a? Array
          p = [perms[0], self.send(:"#{perms[0]}_permissions")].join('__')
          p = nil if p == [perms[0], perms[1].first].join('__')
        elsif perms.is_a? String
          p = perms if self.send(:"#{perms}_permission")
        end
        my_permissions.push p if p.blank? == false
      end
      self.permissions = my_permissions
    end

  end
end
