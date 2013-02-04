class EmployerIdentificationNumberFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    # This regex should match all rules of 
    # http://en.wikipedia.org/wiki/Employer_Identification_Number#EIN_format
    #---------------------------------------------------------------
    if value.nil?
      return true
    end
    
    unless value =~ /^(\d{2}-\d{7})|(\d{2}\d{7})$/
      object.errors[attribute] << (options[:message] || "is not formatted properly")
    else
      ein_numbers = value.gsub(/[^0-9]/, "")

      # Validate SSN length
      #-----------------------------
      if ein_numbers.length > 9
        object.errors[attribute] << (options[:message] || "has too many digits")
      elsif ein_numbers.length < 9
        object.errors[attribute] << (options[:message] || "has too few digits")
      end

      # Validate Non-Zero's for any segment
      #-----------------------------
      if ein_numbers[0..1] == "00"
        object.errors[attribute] << (options[:message] || "is an invalid number")
      elsif ein_numbers[2..8] == "0000000"
        object.errors[attribute] << (options[:message] || "is an invalid number")
      end

      # Validate the first two digits
      #-----------------------------
      valid_prefixes = ["10", "12", "60", "67", "50", "53", "01", "02", "03",
                        "04", "05", "06", "11", "13", "14", "16", "21", "22",
                        "23", "25", "34", "51", "52", "54", "55", "56", "57",
                        "58", "59", "65", "30", "32", "35", "36", "37", "38",
                        "61", "15", "24", "40", "44", "94", "95", "80", "90",
                        "33", "39", "41", "42", "43", "48", "62", "63", "64",
                        "66", "68", "71", "72", "73", "74", "75", "76", "77",
                        "81", "82", "83", "84", "85", "86", "87", "88", "91",
                        "92", "93", "98", "99", "20", "26", "27", "45", "46",
                        "47"]
                        
      
      unless valid_prefixes.include? ein_numbers[0..1]
        object.errors[attribute] << (options[:message] || "is an invalid number")
      end
    end
  end
end