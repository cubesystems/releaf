module Releaf
  # Adds boolean_at class method, that can be used to create boolean setter and
  # getter for DateTime, Date and Time fields. It will also create scopes for
  # when given attribute is set and when it is not set.
  module BooleanAt
    module ClassMethods

      # Create boolean setter and getter for given DateTime, Date and Time
      # attributes.
      #
      # Setter will accept "0", 0, false as false, everything else will
      # evaluate to true. Setter accepts TrueClass, FalseClass, String, Fixnum.
      # If you pass nil, it not change current value.
      #
      # Getter returns true or false
      #
      # Unless you add <tt>:without_scopes => true</tt> as last argument, two scopes
      # will be created. One to list all resources with given attribute set and
      # one that does the opposite.
      #
      # For example, if you use
      #
      #   boolean_at :published_at
      #
      # it will create +published+, +published?+, +published=+ methods and
      # +published+ and +unpublished+ scopes.
      #
      # @param args list of DateTime, Date and Time attributes that ends with
      #   _at or _on for which you'd like to create boolean setter and getter
      #   and scopes
      def boolean_at *args
        options = {}
        options = args.pop if args.last.is_a? Hash

        my_table_name = self.table_name

        args.each do |name|
          raise ArgumentError, "column must be of type DateTime, Date or Time" unless [:datetime, :date, :time].include?(self.columns_hash[name.to_s].try(:type).try(:to_sym))
          raise ArgumentError, "column name must end with _at or _on" unless name =~ /_(at|on)$/

          fun_name = name.to_s.sub(/_(at|on)$/, '')

          # create getter
          define_method fun_name do
            self.send(:"#{name}?")
          end
          alias_method :"#{fun_name}?", :"#{fun_name}"

          # create setter
          define_method :"#{fun_name}=" do |b|
            return if b.nil?
            raise ArgumentError unless b.is_a?(FalseClass) or b.is_a?(TrueClass) or b.is_a?(String) or b.is_a?(Fixnum)
            if b == false or b == "0" or b == 0
              self.send(:"#{name}=", nil)
            else
              self.send(:"#{name}=", Time.now)
            end
          end

          unless options[:without_scopes]
            # create scopes
            self.class_eval do
              scope   "#{fun_name}",  where("#{my_table_name}.#{name} IS NOT NULL")
              scope "un#{fun_name}",  where("#{my_table_name}.#{name} IS NULL")
            end
          end
        end

      end
    end

    def self.included base
      base.extend ClassMethods
    end
  end
end
