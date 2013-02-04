module ControllerMacros
  # Leverages Devise::TestHelpers, which are included in our spec_helper.rb
  
  def raise_not_found
    raise ActiveRecord::RecordNotFound
  end

  def raise_denied
    raise CanCan::AccessDenied
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
  
  def do_get_index( format = 'html' )
    get :index, :format => format
  end

  def do_get_new( format = 'html' )
    get :new, :format => format
  end

  def do_post_create( model = nil, attributes = nil, format = 'html' )
    post :create, model => attributes, :format => format
  end

  def do_get_show( id = nil, format = 'html' )
    get :show, :id => id, :format => format
  end

  def do_get_edit( id = nil, format = 'html' )
    get :edit, :id => id, :format => format
  end

  def do_put_update( model = nil, id = nil, attributes = nil, format = 'html' )
    put :update, :id => id, model => attributes, :format => format
  end

  def do_delete_destroy( id = nil, format = 'html' )
    delete :destroy, :id => id, :format => format
  end
end