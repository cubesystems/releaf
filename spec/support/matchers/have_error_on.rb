RSpec::Matchers.define :have_error_on do |attribute, type, options = {}|
  attr_accessor :error_message

  match do |subject|
    return true if subject.errors.where(attribute, type, **options).present?

    self.error_message = "expected to have "

    if options.present?
      self.error_message += ":#{type} error with #{options}"
    elsif type.present?
      self.error_message += ":#{type} error"
    end

    self.error_message += " on :#{attribute} attribute, actual errors: #{subject.errors.where(attribute)}"

    false
  end

  failure_message do |actual|
    self.error_message
  end
end
