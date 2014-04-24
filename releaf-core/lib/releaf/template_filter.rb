module Releaf
  module TemplateFilter

    def self.included base
      base.before_filter :filter_templates
    end

    def filter_templates
      filter_templates_from_hash(params)
    end

    private

    def filter_templates_from_array arr
      return unless arr.is_a? Array
      arr.each do |item|
        if item.is_a? Hash
          filter_templates_from_hash(item)
        elsif item.is_a? Array
          filter_templates_from_array(item)
        end
      end
    end

    def filter_templates_from_hash hsk
      return unless hsk.is_a? Hash
      hsk.delete :_template_
      hsk.delete '_template_'

      filter_templates_from_array(hsk.values)
    end

  end
end
