module Releaf
  class Error < StandardError; end
  class AccessDenied < Error; end
  class FeatureDisabled < Error; end
end
