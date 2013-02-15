class Organization < ActiveRecord::Base
  include ActiveModel::Validations
    
  # Associations - Profile
  #----------------------------------------------------------------------------
  has_many :stores, :inverse_of => :organization

  # Use attr_accessible to control security
  #----------------------------------------------------  
  attr_accessible :name, :website

  # Validate fields before saving them to the DB
  # Custom Validators are found in lib/validators
  #----------------------------------------------------  
  before_validation :strip_name_whitespace
  before_validation :strip_website_whitespace
  validates :name, :presence => true, :uniqueness => true
  validates :website, :presence => true, :uniqueness => true

  # Public
  #----------------------------------------------------------------------------
  public
  
  # Private Methods
  #----------------------------------------------------------------------------
  private
  def strip_name_whitespace
    # Strips leading and trailing whitespace
    unless self.name.nil?
      self.name = self.name.strip
    end
  end

  def strip_website_whitespace
    # Strips leading and trailing whitespace
    unless self.website.nil?
      self.website = self.website.strip
    end
  end
end