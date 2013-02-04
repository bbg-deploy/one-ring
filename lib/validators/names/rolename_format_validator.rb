class RolenameFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    # Check to see if it has one character
    unless value =~ /[a-z]/
      object.errors[attribute] << (options[:message] || "must contain at least one letter.") 
    end
    # Check to see if it only uses valid characters (lowercase letters and underscores)
    unless value =~ /^[a-z_]+$/
      object.errors[attribute] << (options[:message] || "must contain only lowercase letters and/or underscores.") 
    end
  end
end