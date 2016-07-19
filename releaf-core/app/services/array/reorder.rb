class Array::Reorder
  # Utility class for array items reordering.
  #
  # There are 4 possible reordering options: <code>:first, :last, :before and :after</code>.
  #
  # All reorder methods are chainable, so:
  #     Array::Reorder.call(array: [:a, :b, :c, :d, :e, :f], values: [:a, :b], options: {after: :d})
  # will return
  #     [:c, :d, :a, :b, :e, :f]
  #
  # For single value reorder pass is without array wrap
  # Example:
  #    Array::Reorder.call(array: [:a, :b, :c, :d, :e, :f], values: :d, options: :first)
  #
  # For reordering with <code>`first`</code> and <code>`last`</code> options you must give this option as symbols.
  # Example:
  #    Array::Reorder.call(array: [:a, :b, :c, :d, :e, :f], values: [:e, :f], options: :first)
  #
  # For reorderind with <code>`before`</code> and <code>`after`</code> options you must give option together with
  # target value as hash.
  # Example:
  #    Array::Reorder.call(array: [:a, :b, :c, :d, :e, :f], values: [:e, :f], options: {after: :b})

  include Releaf::Service

  attribute :array, Array
  attribute :values, Array
  attribute :options, Object

  def values=(val)
    val = [val] unless val.is_a? Array
    super
  end

  def call
    deleted_values = delete(values)
    index = reorder_index(options)

    values.reverse_each do|value|
      array.insert(index, deleted_values[value])
    end

    array
  end

  def reorder_index(options)
    if options == :first
      0
    elsif options == :last
      array.length
    elsif options[:after]
      index(options[:after]) + 1
    elsif options[:before]
      index(options[:before])
    else
      raise ArgumentError, "unknown reorder option"
    end
  end

  def delete(values)
    deleted = {}

    values.each do|value|
      index = index(value)
      deleted[value] = array[index]
      array.delete_at(index)
    end

    deleted
  end

  def index(value)
    value = value.to_s
    array.index do |existing_value|
      if existing_value.is_a? Hash
        existing_value.keys.first.to_s == value
      else
        existing_value.to_s == value
      end
    end
  end
end
