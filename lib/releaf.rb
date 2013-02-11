require "releaf/slug"
require "releaf/engine"

module Releaf
  mattr_accessor :main_menu
  @@main_menu = [
    'releaf/content',
    '*permissions',
    'releaf/translations'
  ]

  mattr_accessor :base_menu
  @@base_menu = {
    '*permissions' => [
      ['permissions',   %w[releaf/admins releaf/roles]],
    ]
  }

  mattr_accessor :devise_for
  @@devise_for = 'releaf/admin'

  mattr_accessor :layout
  @@layout = "releaf/admin"

  class << self
    def setup
      yield self
    end
  end
end
