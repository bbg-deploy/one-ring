class Credit < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize

  # STI Setup
  # http://www.alexreisner.com/code/single-table-inheritance-in-rails
  # http://www.christopherbloom.com/2012/02/01/notes-on-sti-in-rails-3-0/
  #----------------------------------------------------------------------------
  validate do |credit|
    credit.errors[:type] << "must be a valid subclass of Credit" unless Credit.descendants.map{|klass| klass.name}.include?(credit.type)
  end

  # Make sure our STI children are routed through the parent routes
  def self.inherited(child)
    child.instance_eval do
      alias :original_model_name :model_name
      def model_name
        Credit.model_name
      end
    end
    super
  end

  # My Code
  #----------------------------------------------------------------------------

  # Association
  #----------------------------------------------------------------------------
  belongs_to :ledger
  has_many :entries, :inverse_of => :credit, :dependent => :destroy
  
  # Attributes
  #----------------------------------------------------------------------------
  attr_accessible :ledger, :type, :amount, :date, :payment_profile_id

  # Validations
  #----------------------------------------------------------------------------
  before_validation :round_amount
  validates :ledger, :presence => true, :immutable => true
  validates :type, :presence => true
  validates :date, :presence => true
  validates :amount, :presence => true,
                    :numericality => { :greater_than => 0, :allow_nil => false },
                    :big_decimal_type => true
  validate :subclass_validations

  # Public Instance Methods
  #----------------------------------------------------------------------------
  def accounted_amount
    accounted_amount = BigDecimal.new("0.0")
    self.entries.each do |entry|
      accounted_amount += entry.amount
    end
    return accounted_amount
  end
  
  def balance
    return (self.amount - self.accounted_amount) unless self.amount.nil?
  end
  
  def fully_accounted?
    return (self.balance == BigDecimal.new("0.0"))
  end

  # Private Methods
  #----------------------------------------------------------------------------
  private
  def round_amount
    self.amount = self.amount.round(2) unless self.amount.nil?
  end
  
  def subclass_validations
    # Typecast into subclass to check those validations
    type_class = self.type.classify.constantize unless self.type.nil?
    if (self.class.descends_from_active_record?) && (self.class != type_class) && !(self.type.nil?)
      subclass = self.becomes(type_class)
      self.errors.add(:base, "subclass validations are failing.") unless subclass.valid?
    end
  end
end