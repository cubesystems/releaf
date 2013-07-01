module Releaf
  # Adds input_locales class method, that can be used to set
  # custom input locales for admin UI i18n fields
  module InputLocales
    # class input_locales method for registering custom locales
    #
    # Example:
    # @example
    #   input_locales ["lv", "en", "ru"]
    #
    # @param args array with locales as string
    def input_locales locales
      raise(ArgumentError, "argument must be a array") unless locales.is_a? Array

      # Override available_input_locales with
      # given locales
      unless method_defined? :available_input_locales
        self.singleton_class.instance_eval do
          define_method("available_input_locales") do
            return locales
          end
        end
      end
    end

    def available_input_locales
      Releaf.available_locales
    end
  end
end

ActiveRecord::Base.extend(Releaf::InputLocales)
