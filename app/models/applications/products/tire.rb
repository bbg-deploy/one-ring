class Tire < Product
  include ActiveModel::Validations

  validates :id_number, :presence => true
end
