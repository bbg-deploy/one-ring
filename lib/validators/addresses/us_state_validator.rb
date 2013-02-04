class UsStateValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    valid_states = YAML.load_file("#{Rails.root}/config/locations.yml")['states']
    unless valid_states.include?(value)
      object.errors[attribute] << (options[:message] || "is not formatted properly for a U.S. State")     
    end
  end
end