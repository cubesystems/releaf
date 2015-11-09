module Releaf::Content
  class RouterProxy
    attr_accessor :router, :releaf_route

    def initialize(router, releaf_route)
      self.router = router
      self.releaf_route = releaf_route
    end

    def draw(&block)
      instance_exec(releaf_route, &block)
    end

    def method_missing(method_name, *args, &block)
      if router.respond_to?(method_name)
        router.public_send(method_name, *releaf_route.params(*args), &block)
      else
        super
      end
    end
  end

end
