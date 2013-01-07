module Leaf
  class NodeBase < ActiveRecord::Base
    self.abstract_class = true
  end
end
