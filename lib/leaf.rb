require "leaf/engine"

module Leaf
  mattr_accessor :main_menu
  @@main_menu = [
    'leaf/content',
    '*modules',
    'leaf/aliases'
  ]

  mattr_accessor :alt_menu
  @@alt_menu = []

  class << self
    def setup
      yield self
    end
  end
end
