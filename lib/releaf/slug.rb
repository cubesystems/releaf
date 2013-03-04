module Releaf
  # Provides common methods for finding object by slug. Also overrides to_html
  # method.
  #
  # Simply add this line to your models
  #
  #   include Releaf::Slug
  #
  # or
  #
  #    ActiveRecord::Base.send(:include, Releaf::Slug)
  #
  # to some initializer (<tt>config/initializers/releaf.rb</tt> for example).
  # Then use find_object or find_object! instead of find
  module Slug
    module ClassMethods

      # same as find_object, except that it will raise
      # ActiveRecord::RecordNotFound error if no resource was found.
      def find_object! id_or_slug, scope_name=nil, scope_args=nil
        obj = find_object(id_or_slug, scope_name, scope_args)
        raise ActiveRecord::RecordNotFound  unless obj
        return obj
      end

      # Find object by slug or id.
      #
      # If id_or_slug looks like id, then tries to find by id first
      # Otherwise it will search by slug field.
      #
      # If instance responds to children method, then it's possible to search
      # for hierarchic resources
      #
      # @param id_or_slug either id of object to find (can be String or Fixnum)
      #   or slug (string) slug, may contain slash ('/')
      #
      # @param scope_name optional scope_name to be used for searching. This is
      #   especially useful when you are searching hierarchic resources. For
      #   example you want to find 2nd level active resource.
      #
      # @param scope_args any arguments that are required for scope
      #
      # @return resource
      def find_object id_or_slug, scope_name=nil, scope_args=nil
        raise ArgumentError, "id_or_slug must be String or Fixnum" unless id_or_slug.is_a?(String) or id_or_slug.is_a?(Fixnum)

        unless column_names.include?('slug')
          return scoped_for_find_by_slug(self, scope_name, scope_args).find(id_or_slug)
        end

        # if it looks like id, search by id first
        if id_or_slug.to_s =~ /\A\d+\z/
          obj = scoped_for_find_by_slug(self, scope_name, scope_args).find_by_id(id_or_slug)
          return obj if obj
        end

        unless column_names.include?('ancestry') || self.new.respond_to?(:children)
          return scoped_for_find_by_slug(self, scope_name, scope_args).find_by_slug(id_or_slug)
        else
          slugs = id_or_slug.split('/')

          obj = scoped_for_find_by_slug(self, scope_name, scope_args).find_by_slug( slugs.shift )
          return nil unless obj
          slugs.each do |slug_part|
            obj = scoped_for_find_by_slug(obj.children, scope_name, scope_args).find_by_slug( slug_part )
            return nil unless obj
          end
          return obj
        end
      end

      private

      def scoped_for_find_by_slug obj, scope_name=nil, scope_args=nil
        unless scope_name.blank?
          if scope_args.nil?
            obj.send(scope_name.to_sym)
          else
            obj.send(scope_name.to_sym, *scope_args)
          end
        else
          obj
        end
      end

    end


    module InstanceMethods
      # Ovverrides to_param method to prefer slug field over id (when
      # possible).  It will also generate hearachical uri part if instance
      # supports parrent method, or has ancestry column (ancestry gem
      # {http://rubygems.org/gems/ancestry})
      #
      # @return String or Fixnum
      def to_param
        return id unless self.class.column_names.include?('slug')
        return id if self.slug.blank?
        col_names = self.class.column_names

        if col_names.include?('ancestry')
          return path.pluck(:slug).join('/')
        elsif self.respond_to?(:parent) && parent
          return parent.to_param + '/' + slug
        else
          return slug
        end
      end
    end


    def self.included base
      base.extend ClassMethods
      include InstanceMethods
    end

  end
end
