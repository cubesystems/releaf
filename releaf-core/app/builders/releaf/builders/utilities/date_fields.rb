module Releaf::Builders::Utilities
  class DateFields
    RUBY_TO_JQUERY_DATE_FORMAT_MAP = {
      '-d' => 'd',
      '-j' => 'o',
      '-m' => 'm',
      '3N' => 'l',
      ':z' => 'Z',
      'B' => 'MM',
      'D' => 'mm/dd/y',
      'F' => 'yy-mm-dd',
      'H' => 'HH',
      'I' => 'h',
      'L' => 'l',
      'M' => 'mm',
      'P' => 'tt',
      'R' => 'HH:mm',
      'S' => 'ss',
      'T' => 'HH:mm:ss',
      'X' => 'HH:mm:ss',
      'Y' => 'yy',
      '_m' => 'm',
      'b' => 'M',
      'c' => 'M d HH:mm:ss yy', # not exact translation
      'd' => 'dd',
      'e' => 'd',
      'h' => 'M',
      'j' => 'oo',
      'k' => 'H',
      'l' => 'hh',
      'm' => 'mm',
      'p' => 'TT',
      'r' => 'h:mm:ss TT',
      's' => '@',
      'x' => 'mm/dd/y',
      'y' => 'y'
    }

    # converts date format used by ruby to dateformat used by jquery (when possible)
    #
    # references:
    #   http://www.ruby-doc.org/core-2.0/Time.html#strftime-method
    #   http://api.jqueryui.com/datepicker/#utility-formatDate
    #   http://trentrichardson.com/examples/timepicker/#tp-formatting
    def self.jquery_date_format(ruby_date_format)
      ruby_date_format.gsub(ruby_date_format_regexp) do |match|
        RUBY_TO_JQUERY_DATE_FORMAT_MAP[match[1..-1]]
      end
    end

    def self.ruby_date_format_regexp
      @@jquery_date_replacement_regexp ||= Regexp.new("%(#{RUBY_TO_JQUERY_DATE_FORMAT_MAP.keys.join('|')})")
    end

    def self.normalize_date_or_time_value(value, type)
      case type
      when :date
        value.to_date
      when :datetime
        value.to_datetime
      when :time
        value.to_time
      end
    end

    def self.format_date_or_time_value(value, type)
      return value if value.nil?

      default_format = date_or_time_default_format(type)
      value = normalize_date_or_time_value(value, type)

      if type == :time
        value.strftime(default_format)
      else
        I18n.l(value, format: default_format)
      end
    end

    def self.time_format_for_jquery
      format = date_or_time_default_format(:time)
      jquery_date_format(format)
    end

    def self.date_format_for_jquery
      format = date_or_time_default_format(:date)
      jquery_date_format(I18n.t("default", scope: "date.formats", default: format))
    end

    def self.date_or_time_default_format(type)
      case type
      when :date
        "%Y-%m-%d"
      when :datetime
        "%Y-%m-%d %H:%M"
      when :time
        "%H:%M"
      end
    end
  end
end
