module Releaf
  class Node < ActiveRecord::Base
    COMMON_FIELD_NAME_PREFIX = 'data_'

    acts_as_nested_set
    acts_as_list scope: :parent_id, column: 'item_position'
    include Slug
    self.table_name = 'releaf_nodes'

    serialize :data, Hash
    default_scope order: 'releaf_nodes.item_position'

    validates_presence_of :name, :slug, :content_type
    validates_uniqueness_of :slug, scope: :parent_id

    alias_attribute :to_text, :name

    belongs_to :content, polymorphic: true, dependent: :destroy, class_name: Proc.new{|r| r.content_type.constantize}
    accepts_nested_attributes_for :content

    # FIXME get rid of attr_protected
    attr_protected :none
    after_save :update_settings_timestamp

    acts_as_url :name, url_attribute: :slug, scope: :parent_id

    def build_content(params, assignment_options)
      self.content = content_type.constantize.new(params)
    end


    ##
    # Return node public url
    def url
      if parent_id
        url = parent.url + "/" + slug.to_s
      else
        url = "/" + slug.to_s
      end

      url
    end

    # returns node content object public controller
    def controller
      raise "Missing content object" if content_type.blank?
      return content_type.constantize.controller
    end

    def self.get_object_from_path path, params = {}
      request_data = get_request_data_from_path path, params
      return request_data[:node]
    end

    def self.get_request_data_from_path path, params = {}
      raise ArgumentError, 'path must be String or Array' unless path.is_a?(String) || path.is_a?(Array)

      node = nil
      parent_node = nil
      matched_parts = 0
      request_data = {}

      if path.is_a? String
        path = path.split('?').first.split("/").reject(&:empty?)
      end

      unless params[:locale].nil?
        parent_node = Node.roots.find_by_slug(params[:locale])
      end

      path.each do |part|
        node = Node.where(parent_id: (parent_node ? parent_node.id : nil), slug: part).first
        if node
          parent_node = node
          matched_parts += 1
        else
          node = parent_node
          break
        end
      end

      unless params[:controller].nil?
        if params[:controller] != node.controller.to_s
          node = nil
        end
      end

      request_data = {
        node: node,
        unmatched_parts: path.slice(matched_parts, path.length)
      }

      return request_data
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

    def common_fields_schema
      @_common_fields_schema ||= common_fields_schema_for_instance
    end

    def common_field_names
      @_common_field_names ||= common_fields_schema.map { |f| "#{COMMON_FIELD_NAME_PREFIX}#{f['field_name']}" }
    end

    def common_field_field_type(field_name)
      common_field_options(field_name.sub(/^#{COMMON_FIELD_NAME_PREFIX}/, ''))['field_type']
    end

    def self.load_common_fields_schema

      common_fields_schema_file = Rails.root.to_s+ '/config/common_fields.yml'
      cfschema = if File.exists?(common_fields_schema_file)
        YAML::load_file(common_fields_schema_file)
      else
        []
      end

      raise "common_fields common_fields_schema is not an array" unless cfschema.is_a? Array
      cfschema.each_with_index do |field,i|
        raise "common_fields common_fields_schema contains non-hash element in root node"       unless field.is_a? Hash
        raise "field_name not defined for field ##{i}"                            unless field.has_key?('field_name')
        raise "field_name must be string"                                         unless field['field_name'].is_a? String
        raise "field_type not defined for #{field['field_type']} field"           unless field.has_key?('field_type')
        raise "apply_to not defined for #{field['apply_to']} field"               unless field.has_key?('apply_to')
      end
      return cfschema
    end

    def destroy
      super
      update_settings_timestamp
    end

    def self.updated_at
      Settings['nodes.updated_at']
    end

    def copy_to_node parent_id
      new_node = self.dup

      if content_id.present?
        new_content = content.dup
        new_content.save
        new_node.content_id = new_content.id
      end

      new_node.parent_id = parent_id
      new_node.save

      children.each do |child|
        child.copy_to_node(new_node.id)
      end

      return new_node
    end

    def move_to_node parent_id
      if parent_id != self.id
        self.parent_id = parent_id
        self.save
      end
    end


    private

    def update_settings_timestamp
      Settings['nodes.updated_at'] = Time.now
    end

    def common_fields_schema_for_instance

      full_schema =if defined?(COMMON_FIELDS_SCHEMA)
                     COMMON_FIELDS_SCHEMA.dup
                   else
                     self.class.load_common_fields_schema.dup
                   end

      full_schema.delete_if do |field|
        keep = false

        if field['apply_to'].is_a?(String) && (field['apply_to'] == '*' || field['apply_to'] == self.content_type)
          keep = true
        elsif field['apply_to'].is_a?(Array) && field['apply_to'].include?(self.content_type)
          keep = true
        else
          keep = false
        end

        if keep == true && field.has_key?('deny_for')
          if field['deny_for'].is_a?(String) && (field['deny_for'] == '*' || field['deny_for'] == self.content_type)
            keep = false
          elsif field['deny_for'].is_a?(Array) && field['deny_for'].include?(self.content_type)
            keep = false
          end
        end

        if keep == true && field.has_key?('levels')
          keep = false unless field['levels'].include? level
        end

        !keep
      end

      return full_schema
    end

    def common_field_setter(key, value)
      self.data[key] = value
    end

    def common_field_getter(key)
      self.data.has_key?(key) ? self.data[key] : common_field_default_value(key)
    end

    def common_field_options(key)
      common_fields_schema.each do |field|
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
