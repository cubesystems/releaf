module Releaf::Builders::Toolbox

  def output
    safe_join do
      items.map do |item|
        tag('li', item)
      end
    end
  end

  def items
    []
  end

end
