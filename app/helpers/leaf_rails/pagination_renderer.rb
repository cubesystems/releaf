module PaginationRenderer
  # This class does the heavy lifting of actually building the pagination
  # links. It is used by +will_paginate+ helper internally.
  
  # This is used in admin/base/_index.footer view
  
  class LinkRenderer < WillPaginate::ActionView::LinkRenderer
    
    protected
    
    def page_number(page)
      unless page == current_page
        link(page, page, :rel => rel_value(page), :class => 'button')
      else
        tag(:em, "<span>#{page}</span>", :class => 'current active button')
      end
    end
    
    def gap
      text = '&hellip;'
      %(<span class="gap button disabled">#{text}</span>)
    end
    
    def previous_or_next_page(page, text, classname)
      if page
        link(text, page, :class => classname + ' button')
      else
        tag(:span, "<span>#{text}</span>", :class => classname + ' button disabled')
      end
    end
    
    def link(text, target, attributes = {})
      if target.is_a? Fixnum
        attributes[:rel] = rel_value(target)
        target = url(target)
      end
      attributes[:href] = target
      tag(:a, "<span>#{text}</span>", attributes)
    end
    
  end
end
