module MailerMacros  
  def last_email  
    ActionMailer::Base.deliveries.last
  end  
  
  def reset_email
    ActionMailer::Base.deliveries = []  
  end

  def get_message_part (mail, content_type)
    mail.body.parts.find { |p| p.content_type.match content_type }.body.raw_source
  end

  #TODO: Write some shared examples for testing confirmation emails, etc.
=begin  
  shared_examples_for "confirmation email to" do |user|
    let(:confirmation_email) do
      
    end
    
    
    it "responds unsuccessfully in #{format}" do
      do_get_index(format)
      response.should_not be_success
    end
    it "redirects to admin sign-in in #{format}" do
      do_get_index(format)
      response.code.should eq("302")
      response.should be_redirect
      response.should redirect_to :controller => 'sessions', :action => :new
    end
  end  
=end
end