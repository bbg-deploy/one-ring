class CustomerAuthenticationMailer < Devise::Mailer
  include SendGrid
  sendgrid_category :use_subject_lines
  sendgrid_enable   :ganalytics, :opentrack
end