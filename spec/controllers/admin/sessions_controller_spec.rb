require 'spec_helper'
=begin
describe SessionsController do
  context "as an anonymous user" do
    let(:user) do
      FactoryGirl.create(:user)
    end
    
    it "does not have a current user" do
      subject.current_user.should be_nil
    end

    it "redirects to the root after sign-in" do
#      if session[:post_auth_path]
#        url = session[:post_auth_path]
#        session[:post_auth_path] = nil
#      else
#        url = home_path
#      end
#      url

#      sign_in user
#      response.should redirect_to home_path
    end
  end
  context "as an anonymous user" do
    let(:user) do
      FactoryGirl.create(:user)
    end
    
    before :each do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end
  end
end
=end
#TODO: Figure out authentication call, or maybe that's more for the controller?
#  it "should authenticate with the correct username and password" do
#    user = FactoryGirl.create(:user, username: "bob", password: "bobpass")
#    User.sign_in(user).should == user
#  end
  
#  it "should not authenticate with the correct username and password" do
#    user = FactoryGirl.create(:user, :username => 'bob', :password => 'bobpass')
#    User.authenticate('bob', 'falsepass').should be_nil
#  end 





