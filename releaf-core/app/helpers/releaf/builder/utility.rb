class Releaf::Builder::Utility
  def self.builder_class(controller_class, model_class, builder_type)
    builder_name = builder_class_name(controller_class.name, model_class.name, builder_type)

    unless (Object.const_get(builder_name).is_a?(Class) rescue false)
      builder_name = "Releaf::#{builder_type.to_s.camelize}Builder"
    end

    builder_name.constantize
  end

  def self.builder_class_name(controller_class_name, model_class_name, builder_type)
    controller_class_scope = controller_class_name.split('::')[0...-1].join('::')
    model_class_unscoped = model_class_name.split('::').last

    [
      controller_class_scope,
      "#{model_class_unscoped}#{builder_type.to_s.camelize}Builder"
    ].join("::")
  end
end
