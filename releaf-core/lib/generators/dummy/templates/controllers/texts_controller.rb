class TextsController < ActionController::Base
  def show
    @node = ::Node.find(params[:node_id])
    @text = @node.content
  end
end
