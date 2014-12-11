class Releaf::Builders
  def self.builder_class(controller_class, model_class, builder_type)

    builder_name = builder_class_name(controller_class.name, model_class.name, builder_type)

    begin
      Object.const_get(builder_name).is_a?(Class)
    rescue => e
      builder_name_error = "uninitialized constant #{builder_name}"
      if e.class == NameError && e.message == builder_name_error
        builder_name = "Releaf::Builders::#{builder_type.to_s.camelize}Builder"
      else
        raise
      end
    end

    builder_name.constantize
  end

  def self.builder_class_name(controller_class_name, model_class_name, builder_type)
    controller_class_scope = controller_class_name.split('::')[0...-1].join('::')
    model_class_unscoped = model_class_name.split('::').last

    [
      controller_class_scope,
      "#{model_class_unscoped}#{builder_type.to_s.camelize}Builder"
    ].reject(&:empty?).join("::")
  end

end
