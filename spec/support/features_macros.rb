module FeatureMacros
  def click_link_i link
    find('a', :text => /#{link}/i).click
  end

  def have_content_i content_search
    find('a', :text => /#{content_search}/i)
  end
end
