module Leaf
  class Node < ActiveRecord::Base
    COMMON_FIELD_NAME_PREFIX = 'data_'

    acts_as_nested_set
    acts_as_list :scope => :parent_id
    self.table_name = 'leaf_nodes'

    serialize :data, Hash
    default_scope :order => 'position'

    validates_presence_of :name, :slug, :content_type

    alias_attribute :to_text, :name

    belongs_to :content, :polymorphic => true
    accepts_nested_attributes_for :content

    # FIXME get rid of attr_protected
    attr_protected :none

    def content_object
      self.content
    end

    def content_object_attributes=(new_attr)
      if self.content
        self.content.update_attributes(new_attr)
      else
        nc = new_content(new_attr)
        nc.save

        self.content = nc
        self.update_attribute(:content_id, nc.id)
      end
    end

    def url
      if parent_id
        url = parent.url + "/" + slug.to_s
      else
        url = slug.to_s
      end

      url
    end

    def controller
      controller_class = nil

      if content_object
        controller_class = "#{content_type}_controller".classify.constantize
      end

      controller_class
    end

    def is_controller_node
      if  (content_type =~ /Controller$/i) != nil && content_type.constantize < LeafController
        return true
      else
        return false
      end
    end

    def self.maintain_base_controllers
      locales = Settings.i18n_locales || ['en']
      tree = {}

      # 1) build up controller tree
      Rails.application.routes.routes.routes.map do|r|
        # skip /admin controllers
        if (r.path.spec.to_s =~ /^\/admin/) == nil && !r.defaults[:controller].to_s.empty?
          class_name = "#{r.defaults[:controller]}_controller".classify.constantize
          if class_name < LeafController
            path = r.path.spec.to_s.gsub("(.:format)", "")
            path = path.split("/").reject(&:empty?)

            item = {:controller => class_name, :action => r.defaults[:action]}

            if path.last != ":id"
              if path[0] == ":locale"
                locales.each do |locale|
                  path[0] = locale
                  tree[path.join("/")] = item
                end
              else
                tree[path.join("/")] = item
              end
            end
          end
        end
      end

      # 2) maintain tree against node content
      tree = Hash[tree.sort]
      tree.each do | url, item |
        parent_path = url.split("/")[0...-1].join("/")
        create = false
        n = nil

        slug = url.split("/").last
        content_string = slug + ":" + item[:action].to_s

        if parent_path.empty?
          parent_id = nil
          n = self::get_object_from_path url, :strict => true
          if !n
            create = true
          end
        else
          parent_item = tree[parent_path]
          if parent_item && parent_item[:node]
            parent_id = parent_item[:node].id
            n = Node.where(:parent_id => parent_id, :content_type => item[:controller].to_s, :content_string => content_string ).first
            if !n
              create = true
            end
          end
        end

        if create
          n = Node.create!(:name => slug, :content_type => item[:controller].to_s, :content_string => content_string, :parent_id => parent_id, :slug => slug)
        end

        item[:node] = n
        tree[url] = item

      end
    end

    def self.get_object_from_path path, params = {}
      node = nil
      parent_node = nil

      if path.class == String
        path = path.split("/").reject(&:empty?)
      end

      unless params[:locale].nil?
        parent_node = Node.roots.find_by_slug(params[:locale])
      end

      path.each do |part|
        node = Node.where(:parent_id => (parent_node ? parent_node.id : nil), :slug => part).first
        if node
          parent_node = node
        else
          unless params[:strict].blank?
            node = nil
          else
            node = parent_node
          end
          break
        end
      end

      unless params[:controller].nil?
        if params[:controller] != node.controller.to_s
          node = nil
        end
      end

      node
    end

    def to_s
      name
    end

    def method_missing(method, *args, &block)
      if self.class.column_names.include?('data')
        case method.to_s
        when /^(#{COMMON_FIELD_NAME_PREFIX}(.+))=$/ then
          if common_field_names.include? $1
            return common_field_setter($2, args[0])
          end
        when /^(#{COMMON_FIELD_NAME_PREFIX}(.+))$/ then
          if common_field_names.include? $1
            return common_field_getter($2)
          end
        end
      end

      return super(method, *args, &block)
    end

    def respond_to? method_id, include_private = false
      # this is needed for mass asignment (update_attributes) to work with common_fields
      rt = super(method_id, include_private)
      return true if rt
      return common_field_names.include?(method_id.to_s.sub(/=$/, ''))
    end

    def schema

      return @_schema if @_schema

      schema_file = Rails.root.to_s+ '/config/common_fields.yml'
      if File.exists?(schema_file)
        @_schema = YAML::load_file(schema_file)
      else
        @_schema = []
      end

      raise "common_fields schema is not an array" unless @_schema.is_a? Array
      @_schema.each_with_index do |field,i|
        raise "common_fields schema contains non-hash element in root node"       unless field.is_a? Hash
        raise "field_name not defined for field ##{i}"                            unless field.has_key?('field_name')
        raise "field_name must be string"                                         unless field['field_name'].is_a? String
        raise "field_type not defined for #{field['field_type']} field"           unless field.has_key?('field_type')
        raise "apply_to not defined for #{field['apply_to']} field"               unless field.has_key?('apply_to')
      end

    end

    def level
      return 3
    end

    def common_field_names
      @_common_field_names ||= schema.map { |f| "#{COMMON_FIELD_NAME_PREFIX}#{f['field_name']}" }
    end

    def common_field_field_type(field_name)
      common_field_options(field_name.sub(/^#{COMMON_FIELD_NAME_PREFIX}/, ''))['field_type']
    end

    private


    def common_field_setter(key, value)
      self.data[key] = value
    end

    def common_field_getter(key)
      self.data.has_key?(key) ? self.data[key] : common_field_default_value(key)
    end

    def common_field_options(key)
      schema.each do |field|
        return field if field['field_name'] == key
      end
    end

    def common_field_default_value(key)
      common_field_options(key)['default']
    end

    def new_content(attr)
      raise RuntimeError, 'content_type must be set' unless content_type
      self.content_type.constantize.new(attr)
    end

  end
end
