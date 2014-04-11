module Releaf
  class Node < ActiveRecord::Base
    COMMON_FIELD_NAME_PREFIX = 'data_'
    COMMON_FIELDS_SCHEMA_FILENAME = Rails.root.to_s + '/config/common_fields.yml'

    self.table_name = 'releaf_nodes'

    acts_as_nested_set order_column: :item_position
    acts_as_list scope: :parent_id, column: :item_position

    serialize :data, Hash
    default_scope { order(:item_position) }

    validates_presence_of :name, :slug, :content_type
    validates_uniqueness_of :slug, scope: :parent_id
    validates_length_of :name, :slug, :content_type, maximum: 255

    alias_attribute :to_text, :name

    belongs_to :content, polymorphic: true, dependent: :destroy, class_name: Proc.new { |r| r.content_type }
    accepts_nested_attributes_for :content

    after_save :update_settings_timestamp
    after_validation :run_custom_validations

    acts_as_url :name, url_attribute: :slug, scope: :parent_id, :only_when_blank => true

    def build_content(params, assignment_options=nil)
      self.content = content_class.new(params)
    end

    def content_class
      return nil if content_type.blank?
      content_type.constantize
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
      full_schema = common_fields_full_schema
      full_schema.delete_if do |field|
        common_fields_keep_field?(field) == false
      end
      return full_schema
    end


    def common_field_names
      common_fields_schema.map { |f| "#{COMMON_FIELD_NAME_PREFIX}#{f['field_name']}" }
    end

    def common_field_field_type(field_name)
      common_field_options(field_name.sub(/^#{COMMON_FIELD_NAME_PREFIX}/, ''))['field_type']
    end

    def self.load_common_fields_schema
      cfschema = if File.exists?(COMMON_FIELDS_SCHEMA_FILENAME)
                   YAML::load_file(COMMON_FIELDS_SCHEMA_FILENAME)
                 else
                   []
                 end

      raise "common_fields common_fields_schema is not an array" unless cfschema.is_a? Array
      cfschema.each_with_index do |field, i|
        raise "common_fields common_fields_schema contains non-hash element in root node"       unless field.is_a? Hash
        raise "field_name not defined for field ##{i}"                            unless field.has_key?('field_name')
        raise "field_name must be string"                                         unless field['field_name'].is_a? String
        raise "field_type not defined for #{field['field_name']} field"           unless field.has_key?('field_type')
        raise "apply_to not defined for #{field['field_name']} field"             unless field.has_key?('apply_to')
      end

      return cfschema
    end

    def destroy
      begin
        super
      rescue NameError => e
        raise if content_id.nil? && content_type.nil?
        raise unless e.message == "uninitialized constant #{content_type}"
        # Class was deleted from project.
        # Lets try one more time, but this time set content_type to nil, so
        # rails doesn't try to constantize it
        self.content_id = self.content_type = nil
        self.save(:validate => false)
        retry
      end
      update_settings_timestamp
    end

    def self.updated_at
      Settings['nodes.updated_at']
    end

    def copy_to_node parent_id
      return if parent_id.to_i == id
      return if self.class.find_by_id(parent_id).nil? && !parent_id.blank?

      new_node = self.class.new
      new_node.name = name
      new_node.slug = slug
      new_node.locale = locale
      new_node.content_type = content_type
      new_node.active = active
      new_node.protected = self.protected

      new_node.item_position = self.self_and_siblings[-1].item_position + 1

      if content_id.present?
        new_content = content.dup
        new_content.save
        new_node.content_id = new_content.id
      end

      new_node.parent_id = parent_id
      new_node.maintain_name
      # To regenerate slug
      new_node.slug = nil

      new_node.save

      children.each do |child|
        child.copy_to_node(new_node.id)
      end

      return new_node
    end

    def move_to_node parent_id
      return if parent_id.to_i == id
      return if parent_id.to_i == self.parent_id
      return if self.class.find_by_id(parent_id).nil? && !parent_id.blank?

      self.parent_id = parent_id
      maintain_name
      # To regenerate slug
      self.slug = nil
      self.ensure_unique_url

      self.save
    end

    # Maintain unique name within parent_id scope.
    # If name is not unique add numeric postfix.
    def maintain_name
      postfix = nil
      total_count = 0

      while self.class.where(parent_id: parent_id, name: "#{name}#{postfix}").where("id != ?", id.to_i).count.to_i > 0 do
        total_count += 1
        postfix = "(#{total_count})"
      end

      if postfix
        self.name = "#{name}#{postfix}"
      end
    end

    # Returns closest existing locale starting from object itself
    # @return [String] locale
    def locale
      own = super
      if own
        own
      else
        ancestors.reorder("depth DESC").
          where("locale IS NOT NULL").
          first.try(:locale)
      end
    end

    # Check whether object and all its ancestors are active
    # @return [Boolean] returns true if object is available
    def available?
      !(self_and_ancestors.where(active: false).count > 0)
    end

    def custom_validators
      content_class.try(:acts_as_node_configuration).try(:[], :validators)
    end

    private

    def run_custom_validations
      return if custom_validators.blank?
      self.validates_with *custom_validators
    end

    def update_settings_timestamp
      Settings['nodes.updated_at'] = Time.now
    end

    def common_fields_full_schema
      self.class.load_common_fields_schema.dup
    end

    def common_fields_keep_helper field_options, mode, match_value, default_value=false
      if ['*', content_type].include? field_options[mode]
        return match_value
      elsif field_options[mode].is_a?(Array) && field_options[mode].include?(content_type)
        return match_value
      else
        return default_value
      end
    end

    def common_fields_keep_field? field_options
      keep = common_fields_keep_helper(field_options, 'apply_to', true, false)
      keep = common_fields_keep_helper(field_options, 'deny_for', false, keep) if keep
      if keep && field_options.has_key?('levels')
        keep = false unless field_options['levels'].include? depth
      end
      return keep
    end

    def common_field_setter(key, value)
      self.data[key] = value
    end

    def common_field_getter(key)
      self.data.fetch(key, common_field_default_value(key))
    end

    def common_field_options(key)
      common_fields_schema.each do |field|
        return field if field['field_name'] == key
      end
    end

    def common_field_default_value(key)
      common_field_options(key)['default']
    end

  end
end
