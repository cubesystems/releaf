class Releaf::Settings::NormalizeValue
  include Releaf::Service
  attribute :value, Object
  attribute :input_type, Symbol

  def call
    if self.class.respond_to? normalization_method
      self.class.send(normalization_method, value)
    else
      value
    end
  end

  def normalization_method
    "normalize_#{input_type}"
  end

  def self.normalize_decimal(value)
    value.to_s.sub(",", ".").to_d
  end

  def self.normalize_float(value)
    value.to_s.sub(",", ".").to_f
  end

  def self.normalize_integer(value)
    value.to_i
  end

  def self.normalize_time(value)
    Time.parse(value) if value.present?
  end

  def self.normalize_datetime(value)
    DateTime.parse(value) if value.present?
  end

  def self.normalize_date(value)
    Date.parse(value) if value.present?
  end

  def self.normalize_boolean(value)
    value.to_s == '1'
  end
end
