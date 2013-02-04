class CreddaEmailValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    unless value =~ /^([^@\s]+)@credda.com$/i
      object.errors[attribute] << (options[:message] || "is not a Credda email address") 
    end
  end
end