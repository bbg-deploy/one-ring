class AdminNotificationMailer < ActionMailer::Base
  include SendGrid
  sendgrid_category :use_subject_lines
  sendgrid_enable   :ganalytics, :opentrack

  default :from => "no-reply@credda.com"
  default :to => "bryce.senz@credda.com"

  def new_user(user)
    sendgrid_category "New User"
    @name = user.name
    @username = user.username
    @user_class = user.class.name
    mail(:subject => "You have a new user!")
  end

  def authorize_net_error(user, error)
    sendgrid_category "Third Party Error"
    @name = user.name
    @username = user.username
    @email = user.email
    @phone_number = user.phone_number.phone_number
    @message = error.message
    @trace = error.backtrace
    mail(:subject => "Authorize.net Error")
  end

  def report_error(model, method, message)
    sendgrid_category "Application Error"
    @model = model
    @method = method
    @message = message
    mail(:subject => "Application Error")
  end

  def report_payment(user, amount)
    @name = user.name
    @username = user.username
    @amount = amount.to_s
    mail(:subject => "New Payment")
  end
end