module Releaf::InstanceCache
  extend ActiveSupport::Concern

  included do
    cattr_accessor :cached_instance_methods

    def self.cache_instance_methods(*method_names)
      self.cached_instance_methods = method_names
      method_names.each do|method_name|
        original_method_name = "_noncached_#{method_name}"
        alias_method original_method_name, method_name
        define_method(method_name) do
          instance_cache(method_name) do
            send(original_method_name)
          end
        end
      end
    end
  end

  def instance_cache_store
    @instance_cache_store ||= {}
  end

  def reset_instance_cache
    @instance_cache_store = {}
  end

  def instance_cache(key)
    if instance_cache_store.key?(key)
      instance_cache_store[key]
    else
      instance_cache_store[key] = yield
    end
  end
end
