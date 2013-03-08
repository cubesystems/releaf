module Releaf
  class NodeBase < ActiveRecord::Base
    self.abstract_class = true

    # returns only bottom level, not /^Releaf::/ subclasses
    def self.node_classes
      return _node_classes(self).reject { |n| n.name =~ /^Releaf::/ }
    end

    def self.releaf_fields_to_display action
      column_names - %w[id created_at updated_at position]
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
