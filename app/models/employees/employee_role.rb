class AdminRole < ActiveRecord::Base
  include ActiveModel::Validations
  extend FriendlyId

  friendly_id :name

  # Assignments
  #----------------------------------------------------------------------------
  has_many :admin_assignments, :dependent => :destroy, :inverse_of => :admin
  has_many :admins, :through => :admin_assignments

  # Attributes
  #----------------------------------------------------------------------------
  attr_accessible :name, :description, :permanent
  
  # Validations
  #----------------------------------------------------------------------------
  validates :name, :presence => true, :uniqueness => {:case_sensitive => false}, 
                   :rolename_format => true
  validates :description, :presence => true
  validates :permanent, :inclusion => {:in => [true, false]}
  before_save :downcase_rolename

  def to_s
    self.name
  end

  private
  def downcase_rolename
    self.name.downcase! unless self.name.blank?
  end
end
