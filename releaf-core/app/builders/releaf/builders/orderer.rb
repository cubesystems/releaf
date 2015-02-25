module Releaf::Builders::Orderer
  def orderer(items)
    Releaf::Core::ItemOrderer.new(*items.to_a)
  end
end
