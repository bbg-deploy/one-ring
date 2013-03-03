class Payment < ActiveRecord::Base
  include ActiveModel::Validations
  has_no_table

end