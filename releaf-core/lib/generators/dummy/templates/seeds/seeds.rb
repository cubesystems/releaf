content_manager = Releaf::Permissions::Role.find_by(name: "content manager")
content_manager.default_controller = "admin/nodes"
content_manager.permissions.destroy
content_manager.permissions.build(permission: "controller.admin/nodes")
content_manager.save!