require "rails_helper"

describe Releaf::RouteMapper do
  after(:all) do
    # reset dummy app routes
    Dummy::Application.reload_routes!
  end

  describe "#mount_releaf_at" do
    it "it assigns normalized mount location to Releaf.application.config.mount_location" do
      expect{
        routes.draw do
          mount_releaf_at '/xxxx'
        end
      }.to change{ Releaf.application.config.mount_location }.to("xxxx")

      expect{
        routes.draw do
          mount_releaf_at '/'
        end
      }.to change{ Releaf.application.config.mount_location }.to("")
    end
  end

  describe "#releaf_resources" do
    before do
      routes.draw do
        mount_releaf_at '/admin' do
          releaf_resources :books
        end
      end
    end

    it "mounts resource toolbox route" do
      expect(get: "/admin/books/1/toolbox").to route_to(
        "action"=>"toolbox",
        "controller"=>"admin/books",
        "id"=>"1"
      )
    end

    it "mounts resource destroy confirm route" do
      expect(get: "/admin/books/1/confirm_destroy").to route_to(
        "action"=>"confirm_destroy",
        "controller"=>"admin/books",
        "id"=>"1"
      )
    end

    it "mounts resources index route" do
      expect(get: "/admin/books/").to route_to(
        "action"=>"index",
        "controller"=>"admin/books",
      )
    end

    it "mounts resource create route" do
      expect(post: "/admin/books/").to route_to(
        "action"=>"create",
        "controller"=>"admin/books",
      )
    end

    it "mounts resource new route" do
      expect(get: "/admin/books/new").to route_to(
        "action"=>"new",
        "controller"=>"admin/books",
      )
    end

    it "mounts resource edit route" do
      expect(get: "/admin/books/1/edit").to route_to(
        "action"=>"edit",
        "controller"=>"admin/books",
        "id"=>"1"
      )
    end

    it "mounts resource show route" do
      expect(get: "/admin/books/1").to route_to(
        "action"=>"show",
        "controller"=>"admin/books",
        "id"=>"1"
      )
    end

    it "mounts resource update route" do
      expect(put: "/admin/books/1").to route_to(
        "action"=>"update",
        "controller"=>"admin/books",
        "id"=>"1"
      )
    end

    it "mounts resource destroy route" do
      expect(delete: "/admin/books/1").to route_to(
        "action"=>"destroy",
        "controller"=>"admin/books",
        "id"=>"1"
      )
    end

    context "when toolbox route is disabled with except: option" do
      before do
        routes.draw do
          mount_releaf_at '/admin' do
            releaf_resources :books, except: [:toolbox]
          end
        end
      end

      it "route to page not found" do
        expect(get: "/admin/books/1/toolbox")
          .to route_to(controller: "releaf/root", action: "page_not_found", path: "books/1/toolbox")
      end
    end

    context "when destroy route is skiped within with only: option" do
      before do
        routes.draw do
          mount_releaf_at '/admin' do
            releaf_resources :books, only: [:index]
          end
        end
      end

      it "route to page not found" do
        expect(get: "/admin/books/1/toolbox")
          .to route_to(controller: "releaf/root", action: "page_not_found", path: "books/1/toolbox")
      end
    end

    context "when confirm destroy route is disabled with except: option" do
      before do
        routes.draw do
          mount_releaf_at '/admin' do
            releaf_resources :books, except: [:destroy]
          end
        end
      end

      it "does not mount destroy confirm route" do
        expect(get: "/admin/books/1/confirm_destroy")
          .to route_to(controller: "releaf/root", action: "page_not_found", path: "books/1/confirm_destroy")
      end
    end

    context "when confirm destroy route is skiped within with only: option" do
      before do
        routes.draw do
          mount_releaf_at '/admin' do
            releaf_resources :books, only: [:index]
          end
        end
      end

      it "does not mount destroy confirm route" do
        expect(get: "/admin/books/1/confirm_destroy")
          .to route_to(controller: "releaf/root", action: "page_not_found", path: "books/1/confirm_destroy")
      end
    end

    context "when custom block given" do
      before do
        routes.draw do
          mount_releaf_at '/admin' do
            releaf_resources :books, only: [:index] do
              member do
                get :download
              end
            end
          end
        end
      end

      it "calls it within resources method" do
        expect(get: "/admin/books/1/download").to route_to(
          "action"=>"download",
          "controller"=>"admin/books",
          "id"=>"1"
        )
      end
    end
  end
end
