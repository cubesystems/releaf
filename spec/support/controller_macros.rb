module ControllerMacros
  def login_as_admin factory
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:admin]
      sign_in FactoryGirl.create(factory) # Using factory girl as an example
    end
  end
  #def login_content_admin
    #before(:each) do
      #@request.env["devise.mapping"] = Devise.mappings[:admin]
      #sign_in FactoryGirl.create(:content_admin) # Using factory girl as an example
    #end
  #end
end
