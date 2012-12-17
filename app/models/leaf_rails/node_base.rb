module LeafRails
  class NodeBase < ActiveRecord::Base
    self.abstract_class = true
  end
end
