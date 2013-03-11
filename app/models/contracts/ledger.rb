class Ledger < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize

  # STI Setup
  # http://www.alexreisner.com/code/single-table-inheritance-in-rails
  # http://www.christopherbloom.com/2012/02/01/notes-on-sti-in-rails-3-0/
  #----------------------------------------------------------------------------
  validate do |ledger|
    ledger.errors[:type] << "must be a valid subclass of Ledger" unless Ledger.descendants.map{|klass| klass.name}.include?(ledger.type)
  end

  # Make sure our STI children are routed through the parent routes
  # http://stackoverflow.com/questions/4507149/best-practices-to-handle-routes-for-sti-subclasses-in-rails?rq=1
  def self.inherited(child)
    child.instance_eval do
      alias :original_model_name :model_name
      def model_name
        Ledger.model_name
      end
    end
    super
  end

  # Associations
  #----------------------------------------------------------------------------
  belongs_to :contract
  has_many :credits, :inverse_of => :ledger, :dependent => :destroy
  has_many :debits, :inverse_of => :ledger, :dependent => :destroy
  has_many :entries, :inverse_of => :ledger, :dependent => :destroy

  # Attributes
  #----------------------------------------------------------------------------
  attr_accessible :contract, :type

  # Validations
  #----------------------------------------------------------------------------
  validates :contract, :presence => true, :immutable => true
  validates :type, :presence => true
  
  # State Machine
  #----------------------------------------------------------------------------
=begin
  state_machine :state, :initial => :unpaid do
    event :mark_unpaid do
      transition :paid => :unpaid
    end

    event :mark_paid do
      transition :unpaid => :paid
    end
  end
=end

  # Public Instance Methods
  #----------------------------------------------------------------------------
  def total_owed
    total = BigDecimal.new("0.0")
    self.debits.each do |debit|
      total += debit.amount
    end
    return total
  end
  
  def total_paid
    total = BigDecimal.new("0.0")  
    self.credits.each do |credit|
      total += credit.amount
    end
    return total
  end

  def total_accounted
    total = BigDecimal.new("0.0")  
    self.entries.each do |entry|
      total += entry.amount
    end
    return total
  end
  
  def percentage_paid
    self.total_owed > BigDecimal.new("0") ? ((self.total_paid)/(self.total_owed) * BigDecimal.new("100"))  : BigDecimal.new("0")
  end

  # Default ordering is by date
  def ordered_debits
    self.debits.order("date ASC")
  end
  
  # Default ordering is by date
  def ordered_credits
    self.credits.order("date ASC")
  end

  # Default ordering is by date
  def ordered_transactions
    return (self.debits + self.credits).sort_by(&:date)
  end

  # For use in charting
  def credits_date_array
    data_array = []
    self.credits.each do |credit|
      data_array.push([(credit.date.to_datetime.to_i * 1000).to_s, credit.amount.to_s.to_f])
    end

    return data_array
  end

  # Default accounting method is FIFO
  def do_accounting!
    self.validate_accounting!
    
    self.ordered_credits.each do |credit|
      unless credit.fully_accounted?
        # If credit isn't fully accounted, search for unaccounted debit
        self.ordered_debits.each do |debit|
          while !(debit.fully_accounted?) && !(credit.fully_accounted?)
            entry_amount = max_entry_amount(credit, debit)
            Entry.create!(:ledger => self, :debit => debit, :credit => credit, :amount => entry_amount)
            #Need to reload both so that paid_off? and fully_accounted? are refreshed
            credit.reload
            debit.reload
          end
        end
      end
    end

    return true
  end

  def valid_accounting?
    # Check can't have more accounted than owed or paid
    return false if (self.total_accounted) > (self.total_owed)
    return false if (self.total_accounted) > (self.total_paid)
    
    # Entries should account earliest debits first
    reached_last_accounted_debit = false
    self.ordered_debits.each do |debit|
      if (reached_last_accounted_debit) && !(debit.entries.empty?)
        return false
      elsif !(debit.entries.empty?) && !(debit.fully_accounted?)
        reached_last_accounted_debit = true
      end
    end
    
    # Entries should account earliest debits first
    reached_last_accounted_credit = false
    self.ordered_credits.each do |credit|
      if (reached_last_accounted_credit) && !(credit.entries.empty?)
        return false
      elsif !(credit.entries.empty?) && !(credit.fully_accounted?)
        reached_last_accounted_credit = true
      end
    end

    return true
  end

  def validate_accounting!
    self.entries.destroy_all unless self.valid_accounting?
    self.reload
    return true
  end


  # Private Instance Methods
  #----------------------------------------------------------------------------
  private
  def max_entry_amount(credit, debit)
    unless (credit.nil?) || (debit.nil?)
      return (credit.balance < debit.balance) ? credit.balance : debit.balance
    end
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