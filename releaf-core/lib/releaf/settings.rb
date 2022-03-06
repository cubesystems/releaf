class Releaf::Settings < ActiveRecord::Base

  self.table_name = table_name_prefix + "settings"

  class SettingNotFound < RuntimeError; end

  belongs_to :thing, polymorphic: true, optional: true

  # get the value field, YAML decoded
  def value
    YAML.load(self[:value], permitted_classes: [DateTime, Time, Date]) if self[:value].present?
  end

  # set the value field, YAML encoded
  def value=(new_value)
    self[:value] = new_value.to_yaml
  end

  def rewrite_cache
    Rails.cache.write(cache_key, value)
  end

  def expire_cache
    Rails.cache.delete(cache_key)
  end

  def cache_key
    self.class.cache_key(var, thing)
  end

  scope :registered, -> { where(var: registered_keys, thing_type: nil, thing_id: nil).order(:var) }

  cattr_accessor :registry
  @@registry = {}.with_indifferent_access

  def releaf_title
    var
  end

  def input_type
    metadata[:type] || :text
  end

  def description
    metadata[:description]
  end

  def metadata
    self.class.registry.fetch(var, {})
  end

  def self.register_scoped
    where(var: registered_keys)
  end

  def self.registered_keys
    @@registry.keys
  end

  def self.register(*args)
    Releaf::Settings::Register.call(settings: args)
  end

  def self.supported_types
    [:boolean, :date, :time, :datetime, :integer, :float, :decimal, :email, :text, :textarea, :richtext]
  end

  class << self
    def cache_prefix(&block)
      @cache_prefix = block
    end

    def cache_key(var_name, scope_object)
      scope = ["rails_settings_cached"]
      scope << @cache_prefix.call if @cache_prefix
      scope << "#{scope_object.class.name}-#{scope_object.id}" if scope_object
      scope << var_name.to_s
      scope.join("/")
    end

    def [](key)
      return super(key) unless rails_initialized?
      val = Rails.cache.fetch(cache_key(key, @object)) do
        super(key)
      end
      val
    end

    # set a setting value by [] notation
    def []=(var_name, value)
      super
      Rails.cache.write(cache_key(var_name, @object), value)
      value
    end

    # get or set a variable with the variable as the called method
    # rubocop:disable Style/MethodMissing
    def method_missing(method, *args)
      method_name = method.to_s
      super(method, *args)
    rescue NoMethodError
      # set a value for a variable
      if method_name[-1] == "="
        var_name = method_name.sub("=", "")
        value = args.first
        self[var_name] = value
      else
        # retrieve a value
        self[method_name]
      end
    end

    # destroy the specified settings record
    def destroy(var_name)
      var_name = var_name.to_s
      obj = object(var_name)
      raise SettingNotFound, "Setting variable \"#{var_name}\" not found" if obj.nil?

      obj.destroy
      true
    end

    # retrieve all settings as a hash (optionally starting with a given namespace)
    def get_all(starting_with = nil)
      vars = thing_scoped.select("var, value")
      vars = vars.where("var LIKE '#{starting_with}%'") if starting_with
      result = {}
      vars.each { |record| result[record.var] = record.value }
      result.reverse_merge!(default_settings(starting_with))
      result.with_indifferent_access
    end

    def where(sql = nil)
      vars = thing_scoped.where(sql) if sql
      vars
    end

    # get a setting value by [] notation
    def [](var_name)
      val = object(var_name)
      return val.value if val
    end

    # set a setting value by [] notation
    def []=(var_name, value)
      var_name = var_name.to_s

      record = object(var_name) || thing_scoped.new(var: var_name)
      record.value = value
      record.save!

      value
    end

    def merge!(var_name, hash_value)
      raise ArgumentError unless hash_value.is_a?(Hash)

      old_value = self[var_name] || {}
      raise TypeError, "Existing value is not a hash, can't merge!" unless old_value.is_a?(Hash)

      new_value = old_value.merge(hash_value)
      self[var_name] = new_value if new_value != old_value

      new_value
    end

    def object(var_name)
      return nil unless table_exists?
      thing_scoped.where(var: var_name.to_s).first
    end

    def thing_scoped
      unscoped.where("thing_type is NULL and thing_id is NULL")
    end

    def source(filename)
      Default.source(filename)
    end

    def rails_initialized?
      Rails.application && Rails.application.initialized?
    end

    private

    def default_settings(starting_with = nil)
      return {} unless Default.enabled?
      return Default.instance if starting_with.nil?
      Default.instance.select { |key, _| key.to_s.start_with?(starting_with) }
    end
  end
end
