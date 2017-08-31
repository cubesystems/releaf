RSpec::Matchers.define :match_html do |expected|

  match do |actual|
    normalize_html(actual) == normalize_html(expected)
  end

  def normalize_html string
    string.strip.gsub(/\s+/,' ').gsub(/((>)\s+|\s+(<))/, '\2\3')
  end

  failure_message do |actual|
    "expected that #{actual} would match the HTML structure of #{expected}"
  end


end