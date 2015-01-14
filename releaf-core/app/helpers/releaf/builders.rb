class Releaf::Builders
  def self.builder_class(controller_class, builder_type)
    controller_namespace = controller_class.name.gsub(/Controller$/, "")
    builer_type_name = "#{builder_type.to_s.camelize}Builder"
    builder_class_name = "#{controller_namespace}::#{builer_type_name}"

    begin
      Object.const_get(builder_class_name).is_a?(Class)
    rescue NameError => e
      allowed_errors = [
        "uninitialized constant #{controller_namespace}",
        "uninitialized constant #{builder_class_name}"
      ]
      if allowed_errors.include?(e.message)
        builder_class_name = [default_namespace, builer_type_name].join("::")
      else
        raise
      end
    end

    builder_class_name.constantize
  end

  def self.default_namespace
    name
  end
end
