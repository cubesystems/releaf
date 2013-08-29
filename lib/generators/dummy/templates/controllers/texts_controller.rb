class TextsController < ActionController::Base
  def show
    @node = Releaf::Node.find(params[:node_id])
    @text = @node.content
  end
end
