require "rails_helper"

describe Releaf::Builders::FormBuilder::DateFields, type: :class do
  class FormBuilderTestHelper < ActionView::Base
    include Releaf::ApplicationHelper
    include Releaf::ButtonHelper
    include FontAwesome::Rails::IconHelper
  end

  let(:template){ FormBuilderTestHelper.new }
  let(:object){ Book.new }
  let(:subject){ Releaf::Builders::FormBuilder.new(:book, object, template, {}) }

  describe "#date_or_time_field" do
    it "returns releaf text field with resolved date or time input attributes" do
      allow(subject).to receive(:date_or_time_field_input_attributes)
        .with(:published_at, :datetime, a: 1).and_return(aa: 11)
      allow(subject).to receive(:releaf_text_field)
        .with(:published_at, input: {aa: 11}, label: {b: 1}, field: {c: 3}, options: {field: {type: "datetime"}, d: 4})
        .and_return("_fld")

      expect(subject.date_or_time_field(:published_at, :datetime, input: {a: 1}, label: {b: 1},
                                        field: {c: 3}, options: {d: 4}))
        .to eq("_fld")
    end
  end

  describe "#date_or_time_field_input_attributes" do
    before do
      allow(object).to receive(:published_at).and_return("_val")
      allow(Releaf::Builders::Utilities::DateFields).to receive(:format_date_or_time_value)
        .with("_val", :datetime).and_return("_frmt_val")
      allow(Releaf::Builders::Utilities::DateFields).to receive(:date_format_for_jquery).and_return("_date_frm")
      allow(Releaf::Builders::Utilities::DateFields).to receive(:time_format_for_jquery).and_return("_time_frm")
    end

    it "returns date or time field input attributes" do
      expect(subject.date_or_time_field_input_attributes(:published_at, :datetime, {})).to eq(
        class: "text datetime-picker",
        value: "_frmt_val",
        data: {"date-format"=>"_date_frm", "time-format"=>"_time_frm"}
      )
    end

    it "deep merges given attributes over resolved" do
      expect(subject.date_or_time_field_input_attributes(:published_at, :datetime, data: {"date-format" => "LK"})).to eq(
        class: "text datetime-picker",
        value: "_frmt_val",
        data: {"date-format"=>"LK", "time-format"=>"_time_frm"}
      )
    end
  end

  describe "#releaf_datetime_field" do
    it "returns releaf date or time field with `datetime` option" do
      expect(subject).to receive(:date_or_time_field)
        .with("year", :datetime, input: {a: "b"}, label: {c: "d"}, field: {e: "f"}, options: {g: "h"})
        .and_return("x")

      expect(subject.releaf_datetime_field("year", input: {a: "b"}, label: {c: "d"}, field: {e: "f"}, options: {g: "h"}))
        .to eq("x")
    end
  end

  describe "#releaf_time_field" do
    it "returns releaf date or time field with `time` option" do
      expect(subject).to receive(:date_or_time_field)
        .with("year", :time, input: {a: "b"}, label: {c: "d"}, field: {e: "f"}, options: {g: "h"})
        .and_return("x")

      expect(subject.releaf_time_field("year", input: {a: "b"}, label: {c: "d"}, field: {e: "f"}, options: {g: "h"}))
        .to eq("x")
    end
  end

  describe "#releaf_date_field" do
    it "returns releaf date or time field with `date` option" do
      expect(subject).to receive(:date_or_time_field)
        .with("year", :date, input: {a: "b"}, label: {c: "d"}, field: {e: "f"}, options: {g: "h"})
        .and_return("x")

      expect(subject.releaf_date_field("year", input: {a: "b"}, label: {c: "d"}, field: {e: "f"}, options: {g: "h"}))
        .to eq("x")
    end
  end
end
