module ControllerMacros
  #TODO: Are any of these being used?
  # Leverages Devise::TestHelpers, which are included in our spec_helper.rb
  def raise_not_found
    raise ActiveRecord::RecordNotFound
  end

  def raise_denied
    raise CanCan::AccessDenied
  end

  def login(user, scope)
    scope_sym = scope.to_sym
    user_symbol = class_to_symbol(user)
    unless user_symbol.nil?
      sign_in scope_sym, user
    end
  end

  def confirm_and_login(user)
    user_symbol = class_to_symbol(user)
    unless user_symbol.nil?
      @request.env["devise.mapping"] = Devise.mappings[user_symbol]
      user.confirm!
      sign_in user
    end
  end

  def class_to_symbol(model)
    return model.to_s.underscore.to_sym
  end
end