class AdminNotificationMailer < ActionMailer::Base
  default :from => "no-reply@credda.com"
  default :to => "admin@credda.com"

  def report_new_user(user)
    mail(:subject => "You have a new user!",
         :body => "New user #{user.username} was just created.",
         :template_path => "mailers/admin_notification_mailer")
  end

  def report_error(model, method, message)
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