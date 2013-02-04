class CountryValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    valid_countries = YAML.load_file("#{Rails.root}/config/locations.yml")['countries']
    unless valid_countries.include?(value)
      object.errors[attribute] << (options[:message] || "is not formatted properly for a country")     
    end
  end
end