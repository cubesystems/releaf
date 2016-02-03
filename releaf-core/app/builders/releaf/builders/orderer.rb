module Releaf::Builders::Orderer
  def orderer(items)
    Releaf::ItemOrderer.new(*items.to_a)
  end
end
