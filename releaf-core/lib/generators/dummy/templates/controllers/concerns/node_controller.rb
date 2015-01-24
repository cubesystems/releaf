module NodeController
  extend ActiveSupport::Concern

  included do
    before_filter :load_node
    # node finding helpers
    helper_method :root_node, :menu, :node_active?
  end

  def show
  end

  def root_node
    @root ||= available_roots.find_by(locale: I18n.locale)
  end

  def menu
    @menu ||= root_node.children.where(active: true)
  end

  def node_active? node
    @active_nodes.include? node
  end

  private

  def load_node
    @node = Node.find(params[:node_id])
    @content  = @node.content unless @node.nil?

    @active_nodes = []
    if @node.present?
      @active_nodes += @node.ancestors.reorder(Node.arel_table[:depth])
      @active_nodes << @node
    end
  end
end
