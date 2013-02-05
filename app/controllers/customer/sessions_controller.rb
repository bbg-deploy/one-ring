class Customer::SessionsController < Devise::SessionsController
  # Customizing sessions controller to direct the user
  # back to the page he came from before signing in
  # Otherwise, direct him to the root URL
  #-------------------------------------------------------
  # http://stackoverflow.com/questions/4291755/rspec-test-of-custom-devise-session-controller-fails-with-abstractcontrollerac

  def after_sign_in_path_for(resource)
    if session[:post_auth_path]
      url = session[:post_auth_path]
      session[:post_auth_path] = nil
    else
      url = home_path
    end
    url
  end
end