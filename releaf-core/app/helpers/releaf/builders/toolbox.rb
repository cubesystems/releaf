module Releaf::Builders::Toolbox

  def output
    safe_join do
      items
    end
  end

  def items
    []
  end

end