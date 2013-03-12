class CreditDecision < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize

  # Association
  #----------------------------------------------------------------------------
  belongs_to :application
  
  # Attributes
  #----------------------------------------------------------------------------
  attr_accessible :application

  # Validations
  #----------------------------------------------------------------------------
  before_validation :set_status
  enumerize :status, :in => [:pending, :approved, :denied]
  validates :application, :presence => true, :immutable => true
  validates :status, :presence => true, :inclusion => { :in => ['pending', 'approved', 'denied'] }

  # Public Instance Methods
  #----------------------------------------------------------------------------

  # Private Methods
  #----------------------------------------------------------------------------
  private
  def set_status
    self.status ||= "pending"
  end
end