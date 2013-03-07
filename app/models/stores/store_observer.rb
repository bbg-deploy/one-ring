class StoreObserver < ActiveRecord::Observer
  observe :store

  # After Create
  #----------------------------------------------------------------------------
  def after_create(store)
    AdminNotificationMailer.new_user(store).deliver
  end
end