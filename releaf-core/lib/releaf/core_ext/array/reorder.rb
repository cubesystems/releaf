class Array
  def reorder(values, options)
    Array::Reorder.call(array: self, values: values, options: options)
  end
end
