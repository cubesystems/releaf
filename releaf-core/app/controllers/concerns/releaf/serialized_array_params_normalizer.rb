module Releaf
  module SerializedArrayParamsNormalizer
    extend ActiveSupport::Concern

    included do
      before_filter :normalize_serialized_array_params, if: :normalize_serialized_array_params?
    end

    def normalize_serialized_array_params
      normalizable_resource_array_params.each do|attribute|
        params[:resource][attribute] = [] unless params[:resource].has_key? attribute
      end
    end

    def normalizable_resource_array_params
      resource_class.serialized_attributes
        .select{|attribute, options| options.object_class == Array && resource_array_params.include?(attribute)}
        .collect{|attribute, options| attribute }
    end

    def resource_array_params
      resource_params
        .select{|parameter| parameter.is_a?(Hash) && parameter.length == 1 && parameter.first.last == []}
        .collect{|parameter| parameter.first.first.to_s }
    end

    def normalize_serialized_array_params?
      mass_assigment_action? && resource_class.serialized_attributes?
    end
  end
end
