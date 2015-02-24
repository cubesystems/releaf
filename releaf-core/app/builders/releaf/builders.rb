class Releaf::Builders
  def self.builder_class(scopes, type)
    scopes += inherited_builder_scopes
    scopes.each do |scope|
      builder_class_name = "#{scope}::#{type.to_s.camelize}Builder"
      if builder_defined?(builder_class_name)
        return builder_class_name.constantize
      end
    end

    raise ArgumentError, "unexisting builder (type: #{type}; scopes: #{scopes.join(", ")})"
  end

  def self.builder_defined?(builder_class_name)
    Rails.application.eager_load! unless Rails.application.config.eager_load
    Object.const_defined?(builder_class_name)
  end

  def self.inherited_builder_scopes
    (ancestors.grep(Class) - [Object, BasicObject]).collect{|c| c.name }
  end
end
