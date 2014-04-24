module Releaf
  module JavascriptHelper

    # converts date format used by ruby to dateformat used by jquery (when possible)
    #
    # references:
    #   http://www.ruby-doc.org/core-2.0/Time.html#strftime-method
    #   http://api.jqueryui.com/datepicker/#utility-formatDate
    #   http://trentrichardson.com/examples/timepicker/#tp-formatting
    def jquery_date_format date_format

      raise ArgumentError, "date_format is not a string" unless date_format.is_a? String

      ruby2jquery = {
        '%'   => '%',
        '-d'  => 'd',
        '-j'  => 'o',
        '-m'  => 'm',
        '3N'  => 'l',
        ':z'  => 'Z',
        'A'   => nil,
        'B'   => 'MM',
        'C'   => nil,
        'D'   => 'mm/dd/y',
        'F'   => 'yy-mm-dd',
        'G'   => nil,
        'H'   => 'HH',
        'I'   => 'h',
        'L'   => 'l',
        'M'   => 'mm',
        'P'   => 'tt',
        'R'   => 'HH:mm',
        'S'   => 'ss',
        'T'   => 'HH:mm:ss',
        'U'   => nil,
        'V'   => nil,
        'W'   => nil,
        'X'   => 'HH:mm:ss',
        'Y'   => 'yy',
        'Z'   => nil,
        '_m'  => 'm',
        'a'   => nil,
        'b'   => 'M',
        'c'   => 'M d HH:mm:ss yy', # not exact translation
        'd'   => 'dd',
        'e'   => 'd',
        'g'   => nil,
        'h'   => 'M',
        'j'   => 'oo',
        'k'   => 'H',
        'l'   => 'hh',
        'm'   => 'mm',
        'n'   => nil,
        'p'   => 'TT',
        'r'   => 'h:mm:ss TT',
        's'   => '@',
        't'   => nil,
        'u'   => nil,
        'v'   => nil,
        'w'   => nil,
        'x'   => 'mm/dd/y',
        'y'   => 'y',
        'z'   => nil
      }

      match_regexp = Regexp.new "%( #{ruby2jquery.reject { |k,v| v.nil? }.keys.join('|') })"
      jquery_date_format = date_format.gsub(match_regexp) do |match|
        ruby2jquery[match[1..-1]]
      end

      return jquery_date_format
    end

  end
end
