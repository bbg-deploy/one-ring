class Entry < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize
#  include Currency
  
  # Associations
  #----------------------------------------------------------------------------
  belongs_to :ledger
  belongs_to :debit
  belongs_to :credit

  # Accessible Methods
  #----------------------------------------------------------------------------
  attr_accessible :ledger, :debit, :credit, :amount

  # Validations
  #----------------------------------------------------------------------------
  before_validation :round_amount
  validates :ledger, :presence => true, :immutable => true
  validates :debit, :presence => true, :immutable => true
  validates :credit, :presence => true, :immutable => true
  validates :amount, :presence => true,
                     :numericality => { :greater_than => 0, :allow_nil => false },
                     :big_decimal_type => true
  validate :amount_is_valid
  validate :all_from_the_same_ledger
  
  # Public Instance Methods
  #----------------------------------------------------------------------------
  def get_creditable_matches
    return Entry.where(:credit_id => self.credit.id)
  end

  def get_debitable_matches
    return Entry.where(:debit_id => self.debit.id)
  end

  # Private Methods
  #----------------------------------------------------------------------------
  private
  def round_amount
    self.amount = self.amount.round(2) unless self.amount.nil?
  end
  
  def amount_is_valid
    unless (self.amount.nil?) || (self.credit.nil?) || (self.debit.nil?)
      if (self.credit.balance < self.amount)
        errors.add(:amount, "must be a less than credit total.")
      elsif (self.debit.balance < self.amount)
        errors.add(:amount, "must be a less than debit total.")
      end
    end
  end
  
  def all_from_the_same_ledger
    unless (self.credit.nil?) || (self.debit.nil?)
      # Comparing IDs and Not objects because STI comparisons sometimes fail on typecast
      if (self.ledger.id != self.credit.ledger.id) || (self.ledger.id != self.debit.ledger.id)
        errors.add(:base, "Both Credit and Debit models referenced must belong to this ledger")
      end
    end
  end
end