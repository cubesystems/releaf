RSpec::Matchers.define :cache_instance_method do |method_name|

  match do |actual|
    described_class.cached_instance_methods.include?(method_name)
  end
end
