class SocialSecurityNumberFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    # This regex should match all rules of 
    # http://en.wikipedia.org/wiki/Social_Security_number#Valid_SSNs
    #---------------------------------------------------------------
    if value.nil?
      return true
    end

    unless value =~ /^(\d{3}-\d{2}-\d{4})|(\d{3}\d{2}\d{4})$/
      object.errors[attribute] << (options[:message] || "is not formatted properly")
    else
      ssn_numbers = value.gsub(/[^0-9]/, "")

      # Validate SSN length
      #-----------------------------
      if ssn_numbers.length > 9
        object.errors[attribute] << (options[:message] || "has too many digits")
      elsif ssn_numbers.length < 9
        object.errors[attribute] << (options[:message] || "has too few digits")
      end

      # Validate Non-Zero's for any segment
      #-----------------------------
      if ssn_numbers[0..2] == "000"
        object.errors[attribute] << (options[:message] || "is an invalid number")
      elsif ssn_numbers[3..4] == "00"
        object.errors[attribute] << (options[:message] || "is an invalid number")
      elsif ssn_numbers[5..8] == "0000"
        object.errors[attribute] << (options[:message] || "is an invalid number")
      end

      # Validate other rules
      #-----------------------------
      if ssn_numbers[0..2] == "666"
        object.errors[attribute] << (options[:message] || "is an invalid number")
      elsif ssn_numbers[0..7] == "98765432"
        object.errors[attribute] << (options[:message] || "is an invalid number")
      end
    end
  end
end