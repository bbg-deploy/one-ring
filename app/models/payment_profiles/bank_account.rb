class BankAccount < ActiveRecord::Base
  extend Enumerize
  has_no_table

  belongs_to :payment_profile

  column :payment_profile_id, :integer
  column :first_name, :string
  column :last_name, :string
  column :account_holder, :string
  column :account_type, :string
  column :account_number, :string
  column :routing_number, :string

  attr_accessible :payment_profile, :account_holder, :account_type, :account_number, :routing_number

  enumerize :account_holder, :in => [:personal, :business]
  enumerize :account_type, :in => [:checking, :savings]
  validates :payment_profile, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :account_holder, :presence => true, :inclusion => { :in => ['personal', 'business'] }
  validates :account_type, :presence => true, :inclusion => { :in => ['checking', 'savings'] }
  validates :account_number, :presence => true, :length => { :minimum => 3}
  validates :routing_number, :presence => true, :length => { :minimum => 3}
  after_validation :echeck_validity

  def save(validate = true)
    if (validate) && (self.valid?)
      return true
    elsif (validate) && !(self.valid?)
      return false
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

  def echeck_format
    return build_echeck
  end

  def authorize_net_format
    echeck = build_echeck

    return {
      :bank_account => {
        :account_type => :checking,      # or :savings
        :echeck_type => :web,            # or :ccd, :ppd
        :routing_number => echeck.routing_number,
        :account_number => echeck.account_number,
        :name_on_account => "#{echeck.first_name} #{echeck.last_name}" } }
  end

  private
  def echeck_validity
    echeck = build_echeck
    if (echeck != false)
      validate_echeck(echeck)
    end
  end

  def build_echeck
    echeck = ActiveMerchant::Billing::Check.new(
      :first_name               => self.first_name,
      :last_name                => self.last_name,
      :account_holder_type      => self.account_holder, # Must be "personal" or "business"
      :account_type             => self.account_type,   # Must be "checking" or "savings"
      :account_number           => self.account_number,
      :routing_number           => self.routing_number,
      :number                   => "100"                     # This is just a standard check number
    )

    return echeck
  end


  def validate_echeck(check)
    unless check.valid_routing_number?
      errors.add(:bank_routing_number, "is invalid.")
    end
  end
end