RSpec::Matchers.define :have_number_of_resources do |number_of_resources|

  match do |subject|
    @text = "#{number_of_resources} resources found"
    @node = find "main > section header .totals"
    @node.has_text? @text, exact: true
  end

  failure_message do |subject|
    "expected #{@node.text.inspect} to match #{@text.inspect}"
  end

end
