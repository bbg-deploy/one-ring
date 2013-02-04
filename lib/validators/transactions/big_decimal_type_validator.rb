class BigDecimalTypeValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
     # Ensure that is it BigDecimal type
    unless value.is_a?(BigDecimal)
      object.errors[attribute] << (options[:message] || "must be a BigDecimal.") 
    end
 end
end