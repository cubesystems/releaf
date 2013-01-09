module Leaf
  class NodeBase < ActiveRecord::Base
    self.abstract_class = true

    # returns only bottom level, not /^Leaf::/ subclasses
    def self.node_classes
      return _node_classes(self).reject { |n| n.name =~ /^Leaf::/ }
    end

    private

    def self._node_classes(klass)
      return [klass] if klass.subclasses.blank?

      classes = []

      klass.subclasses.each do |sublcass|
        classes += _node_classes(sublcass)
      end

      return classes
    end

  end
end
