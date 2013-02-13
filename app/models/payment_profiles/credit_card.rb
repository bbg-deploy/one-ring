class CreditCard < ActiveRecord::Base
  extend Enumerize
  has_no_table

  belongs_to :payment_profile

  column :payment_profile_id, :integer
  column :first_name, :string
  column :last_name, :string
  column :brand, :string
  column :credit_card_number, :string
  column :expiration_date, :date
  column :ccv_number, :string

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
end