class StoreAuthenticationMailer < Devise::Mailer
  include SendGrid
  sendgrid_category :use_subject_lines
  sendgrid_enable   :ganalytics, :opentrack

  def approval_notification(record, opts={})
    devise_mail(record, :approval_notification, opts)
  end
end