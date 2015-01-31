module Releaf::Core::AttachmentsComponent
  def self.draw_component_routes router
    router.concern :releaf_richtext_attachmentable do
      router.collection do
        router.post :create_releaf_richtext_attachment
      end
    end
  end
end
