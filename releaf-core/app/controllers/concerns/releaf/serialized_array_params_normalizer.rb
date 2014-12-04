module Releaf
  module SerializedArrayParamsNormalizer
    def normalize_serialized_array_params(parameters)
      normalizable_resource_array_params.each do|attribute|
        parameters[attribute] = [] unless parameters.has_key? attribute
      end

      parameters
    end

    def normalizable_resource_array_params
      resource_class.serialized_attributes
        .select{|attribute, options| options.object_class == Array && resource_array_params.include?(attribute)}
        .collect{|attribute, options| attribute }
    end

    def resource_array_params
      permitted_params
        .select{|parameter| parameter.is_a?(Hash) && parameter.length == 1 && parameter.first.last == []}
        .collect{|parameter| parameter.first.first.to_s }
    end

    def normalize_serialized_array_params?
      mass_assigment_action? && resource_class.serialized_attributes?
    end
  end
end
