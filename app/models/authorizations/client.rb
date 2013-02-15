class Client < ActiveRecord::Base

  def self.authenticate(app_id, app_access_token)
    where(["app_id = ? AND app_access_token = ?", app_id, app_access_token]).first
  end

  before_create :generate_app_access_token
  
  private
  def generate_app_access_token
    # Generates a new random token, checking to make sure no duplicates exist.
    begin
      self.app_access_token = SecureRandom.hex
    end while self.class.exists?(app_access_token: app_access_token)
  end
end
