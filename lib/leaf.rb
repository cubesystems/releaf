require "leaf/engine"

module Leaf
  mattr_accessor :main_menu
  @@main_menu = [
    'leaf/content',
    '*modules',
    'leaf/translations'
  ]

  mattr_accessor :base_menu
  @@base_menu = {}

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
