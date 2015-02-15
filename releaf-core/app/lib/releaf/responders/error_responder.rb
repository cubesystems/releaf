module Releaf::Responders::ErrorResponder
  def template
    self.class.name.split("::").last.gsub(/Responder$/, "").underscore
  end

  def to_html
    render "releaf/error_pages/#{template}", status: status_code
  end
end
