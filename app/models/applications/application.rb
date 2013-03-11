class Application < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize
  
  # Associations
  #----------------------------------------------------------------------------
#  has_many :products, :inverse_of => :lease_application
#  accepts_nested_attributes_for :products
#  has_one :credit_decision, :inverse_of => :lease_application

  # Accessible Methods
  #----------------------------------------------------------------------------
  attr_accessible :application_number, :customer_account_number, :store_account_number,
#                  :products, 
                  :time_at_address, :rent_or_own, :rent_payment,
                  :initial_lease_choice, :id_verified

  # Validations
  #----------------------------------------------------------------------------
#  enumerize :initial_lease_choice, :in => [:low_cost, :low_payments]
#  validates :products, :presence => true
#  validates_associated :products

  # State Machine
  #----------------------------------------------------------------------------
  state_machine :state, :initial => :unclaimed do
    # Events
    #--------------------------------------------------------------------------
    event :claim do
      transition :unclaimed => :claimed
    end

    event :submit do
      transition :claimed => :submitted
    end

    event :deny do
      transition [:submitted, :approved, :finalized] => :denied
    end

    event :approve do
      transition [:submitted, :denied] => :approved
    end

    event :finalize do
      transition :approved => :finalized
    end

    event :complete do
      transition :finalized => :completed
    end

    # State Validations & Functions
    #--------------------------------------------------------------------------
    state all do
      validates :store_account_number, :presence => true, :immutable => true
      validates :matching_email, :presence => true
    end

    state all - [:unclaimed] do
      validates :customer_account_number, :presence => true, :immutable => true
    end

    state all - [:unclaimed, :claimed] do
      validates :time_at_address, :presence => true
      validates :rent_or_own, :presence => true
      validates :rent_payment, :presence => true
#      validate :customer_has_income_sources
    end

    state all - [:unclaimed, :claimed, :submitted] do
#      validates :credit_decision, :presence => true
    end
    
    state all - [:unclaimed, :claimed, :submitted, :approved, :denied] do
#      validates :initial_lease_choice, :presence => true, :inclusion => { :in => ['low_cost', 'low_payments'] }
#      validates :id_verified, :presence => true, :inclusion => { :in => [true] }
    end

    state :completed do
#      validates :lease, :presence => true
    end
  end

  # Named Scopes
  #----------------------------------------------------------------------------
  scope :unclaimed,  where(:state => "unclaimed").order('created_at ASC')
  scope :claimed,    where(:state => "claimed").order('created_at ASC')
  scope :submitted,  where(:state => "submitted").order('created_at ASC')
  scope :approved,   where(:state => "approved").order('created_at ASC')
  scope :denied,     where(:state => "denied").order('created_at ASC')
  scope :finalized,  where(:state => "finalized").order('created_at ASC')
  scope :completed,  where(:state => "completed").order('created_at ASC')

  # Private Methods
  #----------------------------------------------------------------------------
=begin
  def name
    return "#{self.store.name}: #{self.products_list}"
  end

  def products_list
    return self.products.map(&:name).join(", ")
  end

  def products_total_price
    total = BigDecimal.new("0.0")
    self.products.each do |product|
      total += product.price
    end
    return total
  end


  private
  def customer_has_income_sources
    if self.customer.nil?
      errors.add(:customer, "is required.")
    elsif self.customer.income_sources.empty?
      errors.add(:customer, "does not have any listed income sources.")
    end
  end
=end
end