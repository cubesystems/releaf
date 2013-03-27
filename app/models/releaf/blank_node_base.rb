module Releaf
  class BlankNodeBase
    # returns only bottom level, not /^Releaf::/ subclasses
    def self.node_classes
      return _node_classes(self).reject { |n| n.name =~ /^Releaf::/ }
    end

    def self.releaf_fields_to_display action
      []
    end

    def self.node_type
      "Releaf::BlankNodeBase"
    end

    # returns public controller
    def self.controller
      "#{self.name.pluralize}Controller".constantize
    end

    private

    def self._node_classes(klass)
      classes = [klass]

      klass.subclasses.each do |sublcass|
        classes += _node_classes(sublcass)
      end

      return classes
    end

  end
end
