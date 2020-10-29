module NodeController
  extend ActiveSupport::Concern

  included do
    before_action :load_node
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

  def node_class
    # for node routes the node class can be detected from params
    @node_class ||= params[:node_class].constantize
  end

  def site
    # for node routes site can be detected from params
    @site ||= params[:site]
  end

  def node_active? node
    @active_nodes.include? node
  end

  private

  def load_node
    @node = node_class.find(params[:node_id])
    @content  = @node.content unless @node.nil?

    @active_nodes = []
    if @node.present?
      @active_nodes += @node.ancestors.reorder(node_class.arel_table[:depth])
      @active_nodes << @node
    end
  end
end
