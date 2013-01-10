require "leaf/engine"

module Leaf
  mattr_accessor :main_menu
  @@main_menu = [
    'leaf/content',
    'admin/home',
    'leaf/aliases'
  ]

  mattr_accessor :mod_menu
  @@mod_menu = []

  class << self
    def setup
      yield self
    end
  end
end
