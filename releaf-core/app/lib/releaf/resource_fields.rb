class Releaf::ResourceFields < Releaf::ResourceBase

  def excluded_attributes
    super + %w(password password_confirmation encrypted_password)
  end
end
