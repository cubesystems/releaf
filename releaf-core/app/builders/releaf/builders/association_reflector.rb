class Releaf::Builders::AssociationReflector
  delegate :macro, :name, :klass, to: :reflection

  attr_accessor :reflection, :fields, :sortable_column_name, :sortable_cache

  def initialize(reflection, fields, sortable_column_name)
    self.reflection = reflection
    self.fields = fields
    self.sortable_column_name = sortable_column_name.to_sym
  end

  def sortable?
    if @sortable.nil?
      @sortable = (expected_order_clause == actual_order_clause)
    end

    @sortable
  end

  def destroyable?
    if @destroyable.nil?
      @destroyable = reflection
        .active_record
        .nested_attributes_options
        .fetch(reflection.name, {})
        .fetch(:allow_destroy, false)
    end

    @destroyable
  end

  def actual_order_clause
    relation = reflection.klass.all

    if reflection.scope
      relation = relation.instance_exec(reflection.active_record, &reflection.scope)
    end

    extract_order_clause(relation)
  end

  def expected_order_clause
    relation = reflection.klass.all.order(sortable_column_name)
    extract_order_clause(relation)
  end

  def extract_order_clause(relation)
    relation.order_values.map{|value| value_as_sql(value) }.join(", ")
  end

  def value_as_sql(value)
    if value.respond_to?(:to_sql)
      value.to_sql
    else
      value
    end
  end
end
