module FeatureMacros
  # Leverages Warden::Test::Helpers, which are included in our spec_helper.rb
  def confirm_and_login(user, scope)
    user.confirm!
    login_as user, scope: scope
  end  
end