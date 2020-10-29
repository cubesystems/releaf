module ControllerMacros
  def login_as_user factory
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in FactoryBot.create(factory) # Using factory girl as an example
    end
  end
end
