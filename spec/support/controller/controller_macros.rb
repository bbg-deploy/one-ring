module ControllerMacros
  def raise_not_found
    raise ActiveRecord::RecordNotFound
  end

  def raise_denied
    raise CanCan::AccessDenied
  end
end