require "releaf/slug"
require 'releaf/globalize3/fallbacks'
require "releaf/engine"
require "releaf/resources"
require "releaf/boolean_at"


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

  mattr_accessor :yui_js_url
  # @@yui_js_url = 'http://yui.yahooapis.com/3.9.0/build/yui/yui-min.js'
  @@yui_js_url = 'http://yui.yahooapis.com/3.9.0/build/yui-base/yui-base-min.js'
  # @@yui_js_url = 'http://yui.yahooapis.com/3.9.0/build/yui-core/yui-core-min.js'

  # http://yuilibrary.com/yui/docs/api/classes/config.html
  mattr_accessor :yui_config
  @@yui_config = {}


  class << self
    def setup
      yield self
    end
  end
end
