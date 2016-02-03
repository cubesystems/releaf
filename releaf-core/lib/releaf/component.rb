module Releaf::Component
  def resource_route(router, namespace, resource)
    router.namespace :releaf, path: nil do
      if namespace
        router.namespace namespace, path: nil do
          router.releaf_resources(resource)
        end
      else
        router.releaf_resources(resource)
      end
    end
  end
end
