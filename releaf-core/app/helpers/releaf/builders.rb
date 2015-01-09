class Releaf::Builders
  def self.builder_class(controller_class, builder_type)
    builder_namespace = controller_class.name.gsub(/Controller$/, "")
    builer_type_name = "#{builder_type.to_s.camelize}Builder"
    builder_class_name = "#{builder_namespace}::#{builer_type_name}"

    begin
      Object.const_get(builder_class_name).is_a?(Class)
    rescue => e
      allowed_errors = [
        "uninitialized constant #{builder_namespace}",
        "uninitialized constant #{builder_class_name}"
      ]
      if e.class == NameError && allowed_errors.include?(e.message)
        builder_class_name = "Releaf::Builders::#{builder_type.to_s.camelize}Builder"
      else
        raise
      end
    end

    builder_class_name.constantize
  end
end
