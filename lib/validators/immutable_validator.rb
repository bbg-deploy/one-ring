class ImmutableValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    reflection = record.class.reflect_on_association(attribute)
    # For Associations
    if reflection
      # For Polymorphic Associations
      begin
        unless (record.send("#{attribute}_type_was").nil? || !record.send("#{attribute}_type_changed?")) &&
               (record.send("#{attribute}_id_was").nil? || !record.send("#{attribute}_id_changed?"))
          record.errors[attribute] << "cannot be changed."
        end
      # For Regular Associations
      rescue
        unless (record.send("#{attribute}_id_was").nil? || !record.send("#{attribute}_id_changed?"))
          record.errors[attribute] << "cannot be changed."
        end
      end
    # For Attributes
    else
      unless (record.send("#{attribute}_was").nil? || !record.send("#{attribute}_changed?"))
        record.errors[attribute] << "cannot be changed."
      end
    end
  end
end