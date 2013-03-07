class AdminNotificationMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines
  sendgrid_enable   :ganalytics, :opentrack

  default :from => "no-reply@credda.com"
  default :to => "bryce.senz@credda.com"

  def new_user(user)
    sendgrid_category "New User"
    mail(:subject => "You have a new user!",
         :body => "New user #{user.username} was just created.",
         :template_path => "mailers/admin_notification_mailer")
  end

  def authorize_net_error(user, error)
    sendgrid_category "Third Party Error"
    mail(:subject => "Authorize.net Error",
         :body => "Potential Customer: #{user.username}, #{user.email}. Error Message: #{error.message}, Error Trace: #{error.backtrace}",
         :template_path => "mailers/admin_notification_mailer")
  end

  def report_error(model, method, message)
    sendgrid_category "Application Error"
    mail(:subject => "Error with #{model} model, #{method} method",
         :body => message,
         :template_path => "mailers/admin_notification_mailer")
  end

  def report_payment(model, method, message)
    mail(:subject => "Payment with #{model} model, #{method} method",
         :body => message,
         :template_path => "mailers/admin_notification_mailer")
  end
end