module Releaf::Test
  def self.reset!
    Releaf::Content::RoutesReloader.reset!
  end
end
