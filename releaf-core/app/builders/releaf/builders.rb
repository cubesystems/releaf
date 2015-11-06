class Releaf::Builders
  def self.builder_class(scopes, type)
    (scopes + inherited_builder_scopes).each do |scope|
      builder_class = builder_class_at_scope(scope, type)
      return builder_class if builder_class
    end

    raise ArgumentError, "unexisting builder (type: #{type}; scopes: #{scopes.join(", ")})"
  end

  def self.builder_class_at_scope(scope, type)
    builder_class_name = "#{scope}::#{type.to_s.camelize}Builder"

    if constant_defined_at_scope?(scope, Object) && constant_defined_at_scope?(builder_class_name, scope.constantize)
      builder_class_name.constantize
    end
  end

  def self.constant_defined_at_scope?(mapping, at)
    constant_defined = false

    begin
      constant_defined = at.const_get(mapping).present? && mapping.constantize == at.const_get(mapping)
    rescue NameError => error
      raise unless constant_name_error?(error.message, mapping)
    end

    constant_defined
  end

  def self.constant_name_error?(error_message, mapping)
    (error_message =~ /#{mapping}$/).present?
  end

  def self.inherited_builder_scopes
    (ancestors.grep(Class) - [Object, BasicObject]).collect{|c| c.name }
  end
end
