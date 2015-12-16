RSpec::Matchers.define :match_html do |expected|


  match do |actual|
    actual.strip.gsub(/\s+/,' ').gsub('> <', '><') == expected.strip.gsub(/\s+/,' ').gsub('> <', '><')
  end

  failure_message do |actual|
    "expected that #{actual} would match the HTML structure of #{expected}"
  end

end