require "leaf/engine"

module Leaf
  mattr_accessor :main_menu
  @@main_menu = [
    'leaf/content',
    '*modules',
    'leaf/aliases'
  ]

  mattr_accessor :base_menu
  @@base_menu = {}

  class << self
    def setup
      yield self
    end
  end
end
