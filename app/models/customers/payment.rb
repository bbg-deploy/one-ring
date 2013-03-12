class Payment < ActiveRecord::Base
  include ActiveModel::Validations
  has_no_table

=begin
  column :payment_profile_id, :integer
  column :account_number, :string
  column :amount, :string


  attr_accessible :payment_profile, :brand, :credit_card_number, :expiration_date, :ccv_number

  before_validation :set_names
  enumerize :brand, :in => [:visa, :master, :american_express, :discover, :diners_club, :jcb]
  validates :payment_profile, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :brand, :presence => true, :inclusion => { :in => ['visa', 'master', 'american_express', 'discover', 'diners_club', 'jcb'] }
  validates :credit_card_number, :presence => true
  validates :expiration_date, :presence => true
  validates :ccv_number, :presence => true
  after_validation :credit_card_validity

  def save(validate = true)
    if (validate)
      return self.valid?
    else
      return true
    end
  end

  def save!
    if self.valid?
      return self
    else
      raise StandardError, self.errors
    end
  end

  def reload
    return self
  end

  def update_attributes(attributes = {})
    if attributes
      attributes.each do |name, value|
        self.send("#{name}=", value)
        if self.valid?
          return true
        else
          return false
        end
      end
    end
  end

  def card_format
    return build_credit_card
  end

  def authorize_net_format
    card = build_credit_card

    return {
      :credit_card => card }
  end

  private
  def set_names
    self.first_name = self.payment_profile.first_name unless (self.payment_profile.nil?)
    self.last_name = self.payment_profile.last_name unless (self.payment_profile.nil?)
  end

  def credit_card_validity
    credit_card = build_credit_card
    if (credit_card != false)
      validate_card(credit_card)
    end
  end

  def build_credit_card
    if (self.expiration_date.nil?)
      errors.add(:expiration_date, "cannot be nil.")
      return false
    end

    card = ActiveMerchant::Billing::CreditCard.new(
      :first_name               => self.first_name,
      :last_name                => self.last_name,
      :brand                    => self.brand,
      :number                   => self.credit_card_number,
      :month                    => self.expiration_date.month,
      :year                     => self.expiration_date.year,
      :verification_value       => self.ccv_number
    )
    return card
  end

  def validate_card(card)
    unless card.valid?
      card.errors.full_messages.each do |message|
        errors.add(:base, message)
      end
    end
  end



      # Validations
      #----------------------------------------------------------------------------
      before_validation :format_attributes
      before_validation :set_default_payment_type
      validates :date, :presence => true
      enumerize :payment_type, :in => [:credit_card, :echeck, :cash]
      validates :payment_type, :presence => true, :inclusion => { :in => ['credit_card', 'echeck', 'cash'] }
      validates :total, :presence => true,
                        :numericality => { :greater_than => 0, :allow_nil => false },
                        :big_decimal_type => true
      validate :accounted_less_than_total
      validate :balance_greater_than_or_equal_to_zero
    end

    def acts_as_processable
      # State Machine
      #----------------------------------------------------------------------------
      state_machine :process_state, :initial => :unprocessed do
        after_transition any => :received, :do => :notify_payment_received

        event :receive do
          transition :unprocessed => :received
        end

        event :approve do
          transition [:received, :denied] => :approved
        end

        event :deny do
          transition [:received, :approved] => :denied
        end
      end
    end
  end

  # Public Instance Methods
  #----------------------------------------------------------------------------
  def is_debitable?
    return false
  end
  
  def is_creditable?
    return true
  end

  def accounted_amount
    accounted_amount = BigDecimal.new("0.0")
    self.lease_transactions.each do |transaction|
      accounted_amount += transaction.amount
    end
    return accounted_amount
  end
  
  def balance
    if self.total.nil?
      return nil
    else
      return self.total - self.accounted_amount
    end
  end
  
  def positive_balance
    if (self.balance >= BigDecimal.new("0.0"))
      return self.balance
    else
      return self.balance * BigDecimal.new("-1.0")
    end
  end

  def paid_off?
    return (self.balance == BigDecimal.new("0.0"))
  end

  # Private Methods
  #----------------------------------------------------------------------------
  private
  def set_default_payment_type
    if (self.payment_type.nil?)
      self.payment_type = "credit_card"
    end
  end

  def format_attributes
    self.total = round_to_decimal(self.total, 2)
  end  

  def accounted_less_than_total
    if self.total.nil?
      errors.add(:total, "Total cannot be nil.")
    elsif (self.accounted_amount > self.total)
      errors.add(:base, "Accounting error - credit accounted_amount greater than total.")
    end
  end
  
  def balance_greater_than_or_equal_to_zero
    if (self.balance.nil?)
      errors.add(:total, "Total cannot be nil.")
    elsif (self.balance < BigDecimal.new("0.0"))
      errors.add(:base, "Balance cannot be negative.")
    end
  end
=end
end