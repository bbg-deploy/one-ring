# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Onering::Application.initialize!

# Overried the Actionview base error rendering for forms
# http://stackoverflow.com/questions/8713479/custom-html-error-wrappers-for-form-elements
#TODO: Get this to work!
=begin
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  if instance.error_message.kind_of?(Array)
    %(<div class="form-field ferror">#{html_tag}<small class="ferror">&nbsp;
      #{instance.error_message.join(',')}</small></div).html_safe
  else
    %(<div class="form-field ferror">#{html_tag}<small class="ferror">&nbsp;
      #{instance.error_message}</small></div).html_safe
  end
end
=end
ActionView::Base.field_error_proc = Proc.new do |html_tag, instance|
  if instance.error_message.kind_of?(Array)
    %(#{html_tag}<small class="error">#{instance.error_message.join(', ')}</small>).html_safe
  else
    %(#{html_tag}<small class="error">#{instance.error_message}</small>).html_safe
  end
end