class AccessGrant < ActiveRecord::Base
  include ActiveModel::Validations

  # Associations
  #----------------------------------------------------------------------------
  belongs_to :accessible, :polymorphic => true
  belongs_to :client

  # Mass Assignment Attributes
  #----------------------------------------------------------------------------
  attr_accessible :accessible, :client

  # Validations
  #----------------------------------------------------------------------------
  validate :accessible, :presence => true, :immutable => true
  validate :client, :presence => true, :immutable => true
  before_create :generate_tokens

  # Public Methods
  #----------------------------------------------------------------------------
  public
  def self.prune!
    delete_all(["created_at < ?", 3.days.ago])
  end

  def self.authenticate(code, application_id)
    AccessGrant.where("code = ? AND client_id = ?", code, application_id).first
  end

  def generate_tokens
    self.code, self.access_token, self.refresh_token = SecureRandom.hex(16), SecureRandom.hex(16), SecureRandom.hex(16)
  end

  def redirect_uri_for(redirect_uri)
    if redirect_uri =~ /\?/
      redirect_uri + "&code=#{self.code}&response_type=code&state=#{self.state}"
    else
      redirect_uri + "?code=#{self.code}&response_type=code&state=#{self.state}"
    end
  end

  # Note: This is currently configured through devise, and matches the AuthController access token life
  def start_expiry_period!
    self.update_attribute(:access_token_expires_at, Time.now + Devise.timeout_in)
  end
end