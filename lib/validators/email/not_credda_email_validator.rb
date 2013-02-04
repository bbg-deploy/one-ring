class NotCreddaEmailValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if value =~ /^([^@\s]+)@credda.com$/i
      object.errors[attribute] << (options[:message] || "is not allowed as an email address") 
    end
  end
end