class PhoneNumber < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize

  # Associations
  #----------------------------------------------------------------------------
  belongs_to :phonable, :polymorphic => true
 
  # Attributes
  #----------------------------------------------------------------------------
  attr_accessible :phonable, :phone_number_type, :phone_number, :primary, :cell_phone
 
  # Validations
  #----------------------------------------------------------------------------
  before_validation :set_default_phone_number_type
  validates :phonable, :presence => true, :immutable => true
  enumerize :phone_number_type, :in => [:customer, :store]
  validates :phone_number_type, :presence => true, :inclusion => { :in => ['customer', 'store'] }
  validates :phone_number, :presence => true, :phone_number_format => true
  validates :primary, :inclusion => {:in => [true, false]}
  validates :cell_phone, :inclusion => {:in => [true, false]}
  validate  :validate_phone_number_type_match
  
  # Private Methods
  #----------------------------------------------------------------------------
  private
  def set_default_phone_number_type
    if phonable.is_a?(Customer)
      self.phone_number_type ||= :customer
    elsif phonable.is_a?(Store)
      self.phone_number_type ||= :store
    end
  end

  def validate_phone_number_type_match
    if phonable.is_a?(Customer)
      unless (self.phone_number_type.customer?)
        errors.add(:phone_number_type, "Incorrect Phone Number Type")
      end
    elsif phonable.is_a?(Store)
      unless (self.phone_number_type.store?)
        errors.add(:phone_number_type, "Incorrect Phone Number Type")
      end
    end    
  end
end

