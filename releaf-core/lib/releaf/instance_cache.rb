module Releaf::InstanceCache
  extend ActiveSupport::Concern

  included do
    cattr_accessor :cached_instance_methods, :instance_methods_to_cache

    self.cached_instance_methods   = []
    self.instance_methods_to_cache = []

    def self.instance_cache_original_method_name(method_name)
      "instance_cache_original_#{method_name}"
    end

    if respond_to?(:method_added)
      # preserve any previous definitions of method_added
      singleton_class.send(:alias_method, instance_cache_original_method_name(:method_added), :method_added)
    end

    def self.method_added(method_name)
      # call previous definition of method_added if present
      parent_method_added = instance_cache_original_method_name(:method_added)
      send(parent_method_added, method_name) if respond_to?(parent_method_added)

      # see if the newly added method is in the queue needing to be cached
      method_needs_to_be_cached = instance_methods_to_cache.delete(method_name)
      if method_needs_to_be_cached.present?
        create_instance_cache_method_alias(method_name)
      end
    end

    def self.cache_instance_methods(*method_names)
      method_names.each { |method_name| cache_instance_method(method_name) }
    end

    def self.cache_instance_method method_name
      if instance_methods.include?(method_name)
        # method already defined, alias it
        create_instance_cache_method_alias method_name
      else
        # method not defined yet, add to queue
        instance_methods_to_cache << method_name
      end
    end

    def self.create_instance_cache_method_alias method_name
      original_method_name = instance_cache_original_method_name( method_name )
      alias_method original_method_name, method_name
      define_method(method_name) do
        instance_cache(method_name) do
          send(original_method_name)
        end
      end
      self.cached_instance_methods << method_name
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
