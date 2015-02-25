module Releaf::Core
  class ItemOrderer
    # Utility class for array items reordering.
    #
    # There are 4 possible reordering options: <code>:first, :last, :before and :after</code>.
    #
    # All reorder methods are chainable, so:
    #     Releaf::Core::ItemOrderer.new(:a, :b, :c, :d, :e, :f).reorder(:c, :last).reorder([:a, :b], after: :d).result
    # will return
    #     [:d, :a, :b, :e, :f, :c]
    #
    # For reordering with <code>`first`</code> and <code>`last`</code> options you must give this option as symbols.
    # Example:
    #    Releaf::Core::ItemOrderer.new(:a, :b, :c).reorder(:c, :first)
    #
    # For reorderind with <code>`before`</code> and <code>`after`</code> options you must give option together with target value as hash.
    # Example:
    #    Releaf::Core::ItemOrderer.new(:a, :b, :c).reorder(:a, after: :b)

    attr_accessor :list

    def initialize(*args)
      self.list = args
    end

    def result
      list
    end

    def to_a
      result
    end

    def reorder(values, options)
      values = [values] unless values.is_a? Array
      deleted_values = delete(values)
      index = reorder_index(options)

      values.reverse.each do|value|
        list.insert(index, deleted_values[value])
      end

      self
    end

    def reorder_index(options)
      if options == :first
        index = 0
      elsif options == :last
        index = list.length
      elsif options[:after]
        index = index(options[:after]) + 1
      elsif options[:before]
        index = index(options[:before])
      else
        raise ArgumentError, "unknown reorder option"
      end
    end

    def delete(values)
      deleted = {}

      values.each do|value|
        index = index(value)
        deleted[value] = list[index]
        list.delete_at(index)
      end

      deleted
    end

    def index(value)
      value = value.to_s
      list.index do |existing_value|
        if existing_value.is_a? Hash
          existing_value.keys.first.to_s == value
        else
          existing_value.to_s == value
        end
      end
    end

    # Shortcut for creating new ItemOrderer class, ordering and result retrieving.
    #
    #    Releaf::Core::ItemOrderer.reorder([:a, :b, :c, :d, :e, :f], c: :last, [:a, :b] => {after: :d})
    # is same as
    #    Releaf::Core::ItemOrderer.new(:a, :b, :c, :d, :e, :f).reorder(:c, :last).reorder([:a, :b], after: :d).result
    #
    # @param list [Array] array to reorder
    # @param options_list [Hash] hash with reorder options
    # @return [Array] reordered array
    def self.reorder(list, options_list)
      orderer = new(*list)

      options_list.each_pair do|values, options|
        orderer.reorder(values, options)
      end

      orderer.result
    end
  end
end
