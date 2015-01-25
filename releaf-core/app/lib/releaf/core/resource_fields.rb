class Releaf::Core::ResourceFields < Releaf::Core::ResourceBase

  def excluded_attributes
    super + %w(password password_confirmation encrypted_password item_position)
  end
end
