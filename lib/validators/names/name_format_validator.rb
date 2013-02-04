class NameFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    # This regex should allow only letters in a name (or nil)
    #---------------------------------------------------------------
    if value.nil?
      return
    end

    unless value =~ /^[\w\-'\s]+$/
      object.errors[attribute] << (options[:message] || "must contain only letters.") 
    end
  end
end