class PhoneNumber < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize

  # Associations
  #----------------------------------------------------------------------------
  belongs_to :phonable, :polymorphic => true
 
  # Attributes
  #----------------------------------------------------------------------------
  attr_accessible :phonable, :phone_number_type, :phone_number, :primary, :smsable
 
  # Validations
  #----------------------------------------------------------------------------
  validates :phonable, :presence => true, :immutable => true
  validates :phone_number, :presence => true, :phone_number_format => true
  validates :primary, :inclusion => {:in => [true, false]}
  validates :smsable, :inclusion => {:in => [true, false]}
  

  # Public Methods
  #----------------------------------------------------------------------------
  def to_s
    self.phone_number
  end

  # Private Methods
  #----------------------------------------------------------------------------
  private
end

