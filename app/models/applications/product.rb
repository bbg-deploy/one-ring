class Product < ActiveRecord::Base
  include ActiveModel::Validations
  extend Enumerize

  # STI Setup
  # http://www.alexreisner.com/code/single-table-inheritance-in-rails
  # http://www.christopherbloom.com/2012/02/01/notes-on-sti-in-rails-3-0/
  #----------------------------------------------------------------------------
  validate do |product|
    product.errors[:type] << "must be a valid subclass of Product" unless Product.descendants.map{|klass| klass.name}.include?(product.type)
  end

  # Make sure our STI children are routed through the parent routes
  def self.inherited(child)
    child.instance_eval do
      alias :original_model_name :model_name
      def model_name
        Product.model_name
      end
    end
    super
  end

  # My Code
  #----------------------------------------------------------------------------

  # Association
  #----------------------------------------------------------------------------
  belongs_to :application
  
  # Attributes
  #----------------------------------------------------------------------------
  attr_accessible :application, :type, :price, :id_number, :description

  # Validations
  #----------------------------------------------------------------------------
  before_validation :round_amount
  validates :application, :presence => true, :immutable => true
  validates :type, :presence => true
  validates :price, :presence => true,
                    :numericality => { :greater_than => 0, :allow_nil => false },
                    :big_decimal_type => true
  validates :id_number, :presence => true
  validate :subclass_validations

  # Public Instance Methods
  #----------------------------------------------------------------------------

  # Private Methods
  #----------------------------------------------------------------------------
  private
  def round_amount
    self.price = self.price.round(2) unless self.price.nil?
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