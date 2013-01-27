require "leaf/engine"

module Leaf
  mattr_accessor :main_menu
  @@main_menu = [
    'leaf/content',
    '*permissions',
    'leaf/translations'
  ]

  mattr_accessor :base_menu
  @@base_menu = {
    '*permissions' => [
      ['permissions',   %w[leaf/admins leaf/roles]],
    ]
  }

  mattr_accessor :devise_for
  @@devise_for = 'leaf/admin'

  mattr_accessor :layout
  @@layout = "leaf/admin"

  class << self
    def setup
      yield self
    end
  end
end
