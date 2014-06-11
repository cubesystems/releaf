module Releaf::Core::AttachmentsComponent
  def self.draw_component_routes router
    router.concern :attachmentable do
      router.collection do
        router.get  'new_attachment'
        router.post 'new_attachment', action: 'create_attachment'
      end
    end
  end
end
