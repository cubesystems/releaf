module Releaf::Core::Component
  def resource_route(router, namespace, resource)
    router.namespace :releaf, path: nil do
      router.namespace namespace, path: nil do
        router.releaf_resources(resource)
      end
    end
  end
end
