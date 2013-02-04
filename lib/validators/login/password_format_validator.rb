class PasswordFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
     # Check to see if it has one character
    unless value =~ /[a-zA-Z]/
      object.errors[attribute] << (options[:message] || "must contain at least one letter.") 
    end
    # Check to see if it only uses valid characters (letters and digits)
    unless value =~ /^[a-zA-Z0-9]+$/
      object.errors[attribute] << (options[:message] || "must contain only letters and digits") 
    end
 end
end