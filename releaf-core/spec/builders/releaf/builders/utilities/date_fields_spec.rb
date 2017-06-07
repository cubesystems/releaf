require "rails_helper"

describe Releaf::Builders::Utilities::DateFields do
  describe ".jquery_date_format" do
    it "returns Ruby date formaters converted to jQuery date formaters" do
      expect(described_class.jquery_date_format("% %3N %L %M %-d")).to eq("% l l mm d")

      allow(described_class).to receive(:ruby_date_format_regexp).and_return(Regexp.new("%3N"))
      expect(described_class.jquery_date_format("% %3N %L %M %-d")).to eq("% l %L %M %-d")
    end
  end

  describe ".ruby_date_format_regexp" do
    it "returns Regexp for matching Ruby date formaters" do
      expect(described_class.ruby_date_format_regexp).to be_instance_of Regexp
    end

    it "caches compiled regexp" do
      described_class.class_variable_set(:@@jquery_date_replacement_regexp, nil)
      expect(Regexp).to receive(:new).and_call_original.once
      described_class.ruby_date_format_regexp
      described_class.ruby_date_format_regexp
    end
  end

  describe ".format_date_or_time_value" do
    context "when given value type is :time" do
      it "format normalized value to default format with `strftime`" do
        value = Date.parse("15 Jan 2015")
        time = Time.parse("15 Jan 2015 12:10:04")
        allow(described_class).to receive(:date_or_time_default_format).with(:time).and_return("%H:%M")
        allow(described_class).to receive(:normalize_date_or_time_value).with(value, :time).and_return(time)

        expect(described_class.format_date_or_time_value(value, :time)).to eq("12:10")
      end
    end

    context "when empty value given" do
      it "returns given value" do
        expect(described_class.format_date_or_time_value(nil, :time)).to eq(nil)
      end
    end

    context "when given value type is other than :time" do
      it "format normalized value to default format  with `I18n.l`" do
        value = Date.parse("15 Jan 2015")
        time = Time.parse("15 Jan 2015 12:10:04")

        allow(described_class).to receive(:date_or_time_default_format).with(:date).and_return("_format_")
        allow(described_class).to receive(:normalize_date_or_time_value).with(value, :date).and_return(time)
        allow(I18n).to receive(:l).with(time, format: "_format_").and_return("x")
        expect(described_class.format_date_or_time_value(value, :date)).to eq("x")


        allow(described_class).to receive(:date_or_time_default_format).with(:datetime).and_return("_format_")
        allow(described_class).to receive(:normalize_date_or_time_value).with(value, :datetime).and_return(time)
        allow(I18n).to receive(:l).with(time, format: "_format_").and_return("y")
        expect(described_class.format_date_or_time_value(value, :datetime)).to eq("y")
      end
    end
  end

  describe ".time_format_for_jquery" do
    it "returns jquery time format" do
      allow(described_class).to receive(:date_or_time_default_format).with(:time).and_return("xx")
      allow(described_class).to receive(:jquery_date_format).with("xx").and_return("x")
      expect(described_class.time_format_for_jquery).to eq("x")
    end
  end

  describe ".date_format_for_jquery" do
    it "returns jquery time format" do
      allow(described_class).to receive(:date_or_time_default_format).with(:date).and_return("yy")
      allow(I18n).to receive(:t).with("default", scope: "date.formats", default: "yy").and_return("a")
      allow(described_class).to receive(:jquery_date_format).with("a").and_return("l")
      expect(described_class.date_format_for_jquery).to eq("l")
    end
  end

  describe ".normalize_date_or_time_value" do
    context "when :time type given" do
      it "casts value to time" do
        value = Date.parse("15 Jan 2015")
        expect(described_class.normalize_date_or_time_value(value, :time)).to be_instance_of Time
        expect(described_class.normalize_date_or_time_value(value, :time)).to eq(value.to_time)
      end
    end

    context "when :datetime type given" do
      it "casts value to datetime" do
        value = Time.parse("15 Jan 2015 12:10:04")
        expect(described_class.normalize_date_or_time_value(value, :datetime)).to be_instance_of DateTime
        expect(described_class.normalize_date_or_time_value(value, :datetime)).to eq(value.to_datetime)
      end
    end

    context "when :time type given" do
      it "casts value to date" do
        value = DateTime.parse("15 Jan 2015 12:10:04")
        expect(described_class.normalize_date_or_time_value(value, :date)).to be_instance_of Date
        expect(described_class.normalize_date_or_time_value(value, :date)).to eq(value.to_date)
      end
    end
  end

  describe "#date_or_time_default_format" do
    context "when date format requested requested" do
      it "returns `%Y-%m-%d`" do
        expect(described_class.date_or_time_default_format(:date)).to eq("%Y-%m-%d")
      end
    end

    context "when datetime format requested requested" do
      it "returns `%Y-%m-%d %H:%M`" do
        expect(described_class.date_or_time_default_format(:datetime)).to eq("%Y-%m-%d %H:%M")
      end
    end

    context "when time format requested requested" do
      it "returns `%H:%M`" do
        expect(described_class.date_or_time_default_format(:time)).to eq("%H:%M")
      end
    end
  end
end
