class PhoneNumberFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    if value =~ /^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/
      return true
    elsif value =~  /^(?:\+?1[-. ]?)?\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/
      return true
    else
      object.errors[attribute] << (options[:message] || "is not formatted properly for a U.S. number")     
    end
  end
end