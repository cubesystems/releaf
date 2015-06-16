class Releaf::Core::ResourceBase
  attr_accessor :resource_class

  def initialize(resource_class)
    self.resource_class = resource_class
  end

  def excluded_attributes
    %w{id created_at updated_at}
  end

  def localized_attributes?
    resource_class.translates?
  end

  def localized_attributes
    resource_class.translated_attribute_names.collect { |a| a.to_s }
  end

  def base_attributes
    resource_class.column_names - excluded_attributes
  end

  def values(include_associations: true)
    list = base_attributes
    list += localized_attributes if localized_attributes?
    list += associations_attributes if include_associations
    list
  end


  def associations_attributes
    associations.collect do |association|
      {association.name => association_attributes(association)}
    end
  end

  def association_attributes(association)
    self.class.new(association.klass).values - association_excluded_attributes(association)
  end

  def association_excluded_attributes(association)
    [association.foreign_key, association.type].compact.map(&:to_s)
  end

  def associations
    resource_class.reflect_on_all_associations.collect do |association|
      association if includable_association?(association)
    end.compact
  end

  def includable_association?(association)
    includable_association_types.include?(association.macro) &&
      excluded_associations.exclude?(association.name) &&
      association.class != ActiveRecord::Reflection::ThroughReflection &&
      resource_class.nested_attributes_options.has_key?(association.name)
  end

  def includable_association_types
    [:has_many, :has_one]
  end

  def excluded_associations
    [:translations]
  end
end
