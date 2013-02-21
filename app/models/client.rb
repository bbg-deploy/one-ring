class Client < ActiveRecord::Base
  include ActiveModel::Validations

  # Associations
  #----------------------------------------------------------------------------
  has_many :access_grants, :dependent => :destroy

  # Mass Assignment Attributes
  #----------------------------------------------------------------------------
  attr_accessible :name, :redirect_uri

  # Validations
  #----------------------------------------------------------------------------
  before_validation :strip_name_whitespace
  before_validation :generate_app_access_token
  validates :name, :presence => true, :length => {:minimum => 6, :maximum => 20},
                     :client_name_format => true
  validates :redirect_uri, :presence => true, :uniqueness => true, :redirect_uri => true
  validates :app_id, :presence => true, :uniqueness => true
  validates :app_access_token, :presence => true, :uniqueness => true

  def self.authenticate(app_id, app_access_token)
    where(["app_id = ? AND app_access_token = ?", app_id, app_access_token]).first
  end
  
  private
  def generate_app_access_token
    # Generates a new random token, checking to make sure no duplicates exist.
    begin
      self.app_access_token = SecureRandom.hex
    end while self.class.exists?(app_access_token: app_access_token)

    begin
      self.app_id = SecureRandom.hex
    end while self.class.exists?(app_id: app_id)
  end

  def strip_name_whitespace
    # Strips leading and trailing whitespace
    self.name = self.name.strip unless self.name.nil?
  end
end
