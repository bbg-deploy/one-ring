class Address < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize

  # Associations
  #----------------------------------------------------------------------------
  belongs_to :addressable, :polymorphic => true

  # Attributes
  #----------------------------------------------------------------------------
  attr_accessible :addressable, :address_type, :street, :city, :state, :zip_code, :country
  attr_protected :latitude, :longitude

  # User-Accessible Attributes
  #----------------------------------------------------------------------------
  before_validation :set_default_address_type, :on => :create
  validates :addressable, :presence => true, :immutable => true
  enumerize :address_type, :in => [:mailing, :billing, :store]
  validates :address_type, :presence => true, :inclusion => { :in => ['mailing', 'billing', 'store'] }
  validates :street, :presence => true
  validates :city, :presence => true
  validates :state, :presence => true, :us_state => true
  validates :zip_code, :presence => true
  validates :country, :presence => true, :country => true
  validate  :validate_address_type_match
  after_validation :geocode          # auto-fetch coordinates
  geocoded_by :full_address
  
  # Public Methods
  #----------------------------------------------------------------------------
  def full_address
    [self.street, self.city, self.state, self.country].compact.join(', ')
  end
  
  # Private Methods
  #----------------------------------------------------------------------------
  private
  def set_default_address_type
    if addressable.is_a?(Customer)
      self.address_type ||= :mailing
    elsif addressable.is_a?(PaymentProfile)
      self.address_type ||= :billing
    elsif addressable.is_a?(Store)
      self.address_type ||= :store
    end
  end
  
  def validate_address_type_match
    if addressable.is_a?(Customer)
      unless (self.address_type.mailing?)
        errors.add(:address_type, "Incorrect Address Type")
      end
    elsif addressable.is_a?(PaymentProfile)
      unless (self.address_type.billing?)
        errors.add(:address_type, "Incorrect Address Type")
      end
    elsif addressable.is_a?(Store)
      unless (self.address_type.store?)
        errors.add(:address_type, "Incorrect Address Type")
      end
    end    
  end
end