class UsernameFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    # Check to see if it has one character
    if value == nil      
      object.errors[attribute] << (options[:message] || "must not be blank.") 
    else
      unless value =~ /[a-zA-Z]/
        object.errors[attribute] << (options[:message] || "must contain at least one letter.") 
      end
      # Check to see if it only uses valid characters (letters, digits, and underscores)
      unless value =~ /^[a-zA-Z0-9_]+$/
        object.errors[attribute] << (options[:message] || "must contain only letters, digits, or underscores.") 
      end
      # Check to see that the username begins with a letter    
      unless value[0] =~ /[a-zA-Z]/
        object.errors[attribute] << (options[:message] || "must begin with a letter.") 
      end
    end
  end
end