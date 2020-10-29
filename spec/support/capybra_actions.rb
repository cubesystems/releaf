module CapybaraActions
  def blur_from(locator)
    field = find_field(locator)
    field.native.send_keys :tab
  end
end
