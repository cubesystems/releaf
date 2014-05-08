module ExcelHelpers
  class ExcelMatcher
    require 'roo'

    def initialize(fixture_path)
      @fixture_path = fixture_path
      @errors = []
    end

    def matches?(actual_path)
      match_excel(actual_path)

      @errors.empty?
    end

    def failure_message_for_should
      "Following cells differ from expected: #{error_messages}"
    end

    private

    def error_messages
      messages = []
      @errors.each do |error|
        messages << "#{error[:cell]} (expect: #{error[:fixture_value]} was: #{error[:actual_value]})"
      end

      messages.join(', ')
    end

    def match_excel actual_path
      fixture = Roo::Spreadsheet.open(@fixture_path)
      fixture.default_sheet = fixture.sheets.first

      actual = Roo::Spreadsheet.open(actual_path)
      actual.default_sheet = actual.sheets.first

      match_sheet(actual, fixture)
    end

    def match_sheet actual, fixture
      rows = fixture.first_row..fixture.last_row
      columns = fixture.first_column..fixture.last_column
      for row in rows
        for column in columns
          fixture_value = fixture.cell(row, column)
          actual_value = actual.cell(row, column)
          if fixture_value != actual_value
            @errors << {
              cell: "#{Roo::Base.number_to_letter(column)}#{row}",
              fixture_value: fixture_value,
              actual_value: actual_value
            }
          end
        end
      end
    end
  end

  def match_excel(fixture_path)
    ExcelMatcher.new(fixture_path)
  end
end
