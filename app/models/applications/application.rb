class Application < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize
  
  # Associations
  #----------------------------------------------------------------------------
  has_many :products, :inverse_of => :application
  has_many :terms_options, :inverse_of => :application
  accepts_nested_attributes_for :products
  has_one :credit_decision, :inverse_of => :application

  # Accessible Methods
  #----------------------------------------------------------------------------
  attr_accessible :customer_account_number, :store_account_number, :matching_email,
                  :products, :products_attributes, :time_at_address, :rent_or_own, :rent_payment,
                  :initial_lease_choice, :id_verified

  # Validations
  #----------------------------------------------------------------------------
  validates :products, :presence => true
  validates_associated :products
  before_validation :generate_application_number, :on => :create
  validates :application_number, :presence => true, :uniqueness => true

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
      validates :credit_decision, :presence => true
    end
    
    state all - [:unclaimed, :claimed, :submitted, :approved, :denied] do
      validates :id_verified, :presence => true, :inclusion => { :in => [true] }
    end

    state :completed do
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
  def store_name
    store = Store.where(:account_number => self.store_account_number).first
    store.name
  end

  def name
    return "#{self.store_name}: #{self.products_list}"
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
=begin
  def customer_has_income_sources
    if self.customer.nil?
      errors.add(:customer, "is required.")
    elsif self.customer.income_sources.empty?
      errors.add(:customer, "does not have any listed income sources.")
    end
  end
=end
  private
  def generate_application_number
    if self.application_number.nil?
      begin
        token = 'LTOAPP' + SecureRandom.hex(5).upcase
      end if Application.where({:application_number => token}).empty?
      self.application_number = token
    end
  end
end