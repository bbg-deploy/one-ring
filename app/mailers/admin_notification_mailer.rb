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

  def authorize_net_error(object, error)
    sendgrid_category "Third Party Error"
#    @name = user.name
#    @username = user.username
#    @email = user.email
#    @phone_number = user.phone_number.phone_number
    if object.is_a?(Customer)
      @object_details = {
        :name => object.try(:name),
        :username => object.try(:username),
        :email => object.try(:email),
        :phone_number => object.try(:phone_number)
      }
    elsif object.is_a?(PaymentProfile)
      @object_details = {
        :name => object.try(:name),
        :username => object.try(:username),
        :email => object.try(:email),
        :phone_number => object.try(:phone_number)
      }
    elsif object.is_a?(Payment)
      
    end
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