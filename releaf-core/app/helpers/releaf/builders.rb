class Releaf::Builders
  def self.builder_class(scopes, type)
    (scopes + inherited_builder_scopes).each do |scope|
      resolved_class = scoped_builder_class(scope, type)
      return resolved_class if resolved_class
    end
  end

  def self.scoped_builder_class(scope, type)
    builder_class_name = "#{scope}::#{type.to_s.camelize}Builder"

    begin
      Object.const_get(builder_class_name).is_a?(Class)
    rescue NameError => error
      if ignorable_error?(error.message, builder_class_name)
        return
      else
        raise
      end
    end

    builder_class_name.constantize
  end

  def self.ignorable_error?(error_message, builder_class_name)
    (error_message =~ ignorable_error_pattern(builder_class_name)).present?
  end

  def self.ignorable_error_pattern(builder_class_name)
    list = []
    tmp_scopes = builder_class_name.split("::")
    while(tmp_scopes.present?)
      list << tmp_scopes.join("::")
      tmp_scopes.pop
    end

    /uninitialized constant (#{list.join("|")})$/
  end

  def self.inherited_builder_scopes
    (ancestors.grep(Class) - [Object, BasicObject]).collect{|c| c.name }
  end
end
