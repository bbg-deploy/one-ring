module Authentication
  extend ActiveSupport::Concern

  included do
    include ActiveModel::Validations
    extend FriendlyId
  end

  module ClassMethods
    def has_friendly_username #FriendlyID for prettier URLs
      friendly_id :username
    end
    
    def is_terms_agreeable #User needs to agree to terms to register
      # Attributes
      #----------------------------------------------------------------------------
      attr_accessible :terms_agreement

      # Validations
      #----------------------------------------------------------------------------
      validates :terms_agreement, :acceptance => true, :allow_nil => :false, :on => :create
    end

    def is_authenticatable #Allows authentication with username & password
      devise :database_authenticatable, :trackable,
             :case_insensitive_keys => [:email, :username],
             :strip_whitespace_keys => [:email, :username],
             :authentication_keys => [:login]
             
      # Attributes
      #----------------------------------------------------------------------------
      attr_accessor :login, :current_password
      attr_accessible :login, :username, :email, :email_confirmation, 
                      :current_password, :password, :password_confirmation,
                      :remember_me
                      
      # Validations
      #----------------------------------------------------------------------------
      # Limit the username length to 20, since that's the limit in the Authorize.net API for
      # storing a reference ID.  Not the biggest deal if we change that,
      # but 20 keeps us in line with their standards
      before_validation :strip_username_whitespace
      before_validation :strip_email_whitespace
      validates :username, :presence => true, :uniqueness => {:case_sensitive => true}, 
                           :username_format => true, 
                           :exclusion => { :in => ['admin', 'demo'] },
                           :length => { :in => 4..20 }
      validates :email, :presence => true
      validates :email, :uniqueness => true, :email_format => true, :if => :email
      validates_confirmation_of :email, :if => :changed_email
      validates :password, :presence => true, :on => :create
      validates :password, :password_format => true, :length => { :minimum => 4 }, :if => :password
      validates_confirmation_of :password, :if => :password


      def self.find_first_by_auth_conditions(warden_conditions)
        conditions = warden_conditions.dup
        if login = conditions.delete(:login)
          where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
        else
          where(conditions).first
        end
      end      
    end

    def is_registerable #User can register on his/her own & manage his/her account
      devise :registerable
    end

    def is_confirmable #Sends email with confirmation instructions
      devise :confirmable,
             :reconfirmable => true,
             :confirmation_keys => [:email]
    end

    def is_recoverable #Resets the user password and sends reset instructions
      devise :recoverable,
             :reset_password_keys => [:email],
             :reset_password_within => 6.hours
    end

    def is_lockable #Locks an account after a specific number of failed login attempts
      devise :lockable,
             :unlock_keys => [:email],
             :unlock_strategy => :both,
             :maximum_attempts => 5,
             :unlock_in => 1.hour
    end

    def is_rememberable #Generates and clears a token via a cookie
      devise :rememberable,
             :remember_for => 2.weeks
    end

    def is_timeoutable #Expires sessions that haven't been active for a period of time
      devise :timeoutable,
             :timeout_in => 30.minutes
    end    
  end

  def to_s
    username
  end
    
  def cancel_account!
    self.cancelled_at = DateTime.now
    self.save!
  end

  def cancelled?
    return !self.cancelled_at.nil?
  end

  private
  def changed_email
    return self.email_changed?
  end

  def strip_username_whitespace
    # Strips leading and trailing whitespace
    unless self.username.nil?
      self.username = self.username.strip
    end
  end

  def strip_email_whitespace
    # Strips ALL whitespace from email entries
    unless self.email.nil?
      self.email = self.email.gsub(/\s+/, "")
    end
    unless self.email_confirmation.nil?
      self.email_confirmation = self.email_confirmation.gsub(/\s+/, "")
    end
  end
end