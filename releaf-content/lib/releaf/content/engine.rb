module Releaf::Content
  class Engine < ::Rails::Engine
  end

  def self.draw_component_routes router
    router.namespace :content, path: nil do
      router.releaf_resources :nodes, :except => [:show] do
        router.collection do
          router.get :generate_url
          router.get :go_to_dialog
        end

        router.member do
          router.get :copy_dialog
          router.post :copy
          router.get :move_dialog
          router.post :move
        end
      end
    end
  end
end
