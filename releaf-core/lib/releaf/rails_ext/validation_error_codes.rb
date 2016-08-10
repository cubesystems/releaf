module ActiveModel
  class ErrorMessage < String
    attr_accessor :error_code, :data

    def initialize(message, error_code = nil, data = nil)
      super message
      @error_code = error_code
      @data = data
    end
  end

  class Errors
    def add(attribute, message = nil, options = {})
      # build error code from message symbol
      error_code = normalize_error_code(attribute, message, options)
      message = normalize_message(attribute, message, options)
      if exception = options[:strict]
        exception = ActiveModel::StrictValidationFailed if exception == true
        raise exception, full_message(attribute, message)
      end

      # use customized String subclass with "error_code" attribute
      self[attribute] << ErrorMessage.new(message, error_code, options[:data])
    end

    def normalize_error_code(_attribute, message, options)
      if !options[:error_code].blank?
        options[:error_code]
      elsif message.class == Symbol
        message
      else
        :invalid
      end
    end
  end
end
