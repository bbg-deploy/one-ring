require 'spec_helper'
 
describe AdminNotificationMailer do
  def get_message_part (mail, content_type)
    mail.body.parts.find { |p| p.content_type.match content_type }.body.raw_source
  end

  describe 'new_user', :new_user => true  do
    context "with Customer" do
      let(:user) { FactoryGirl.create(:customer) }
      let(:mail) { AdminNotificationMailer.new_user(user) }

      it "generates a multipart message (plain text and html)" do
        mail.body.parts.length.should eq(2)
        mail.body.parts.collect(&:content_type).should == ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
      end
        
      it "renders the subject" do
        mail.subject.should eq("You have a new user!")
      end

      it "sends to administrator" do
        mail.to.should eq(["bryce.senz@credda.com"])
      end

      it "sends from no-reply" do
        mail.from.should eq(["no-reply@credda.com"])
      end

      it "has a body" do
        mail.body.should_not be_nil
      end

      describe "HTML body" do
        let(:body) { get_message_part(mail, /html/) }

        it "should include user's name" do
          body.should match(user.name)
        end

        it "should include user's Class" do
          body.should match(user.class.name)
        end

        it "should include user's username" do
          body.should match(user.username)
        end
      end

      describe "text body" do
        let(:body) { get_message_part(mail, /plain/) }

        it "should include user's name" do
          body.should match(user.name)
        end

        it "should include user's Class" do
          body.should match(user.class.name)
        end

        it "should include user's username" do
          body.should match(user.username)
        end
      end
    end

    context "with Store" do
      let(:user) { FactoryGirl.create(:store) }
      let(:mail) { AdminNotificationMailer.new_user(user) }

      it "generates a multipart message (plain text and html)" do
        mail.body.parts.length.should eq(2)
        mail.body.parts.collect(&:content_type).should == ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
      end
        
      it "renders the subject" do
        mail.subject.should eq("You have a new user!")
      end

      it "sends to administrator" do
        mail.to.should eq(["bryce.senz@credda.com"])
      end

      it "sends from no-reply" do
        mail.from.should eq(["no-reply@credda.com"])
      end

      it "has a body" do
        mail.body.should_not be_nil
      end

      describe "HTML body" do
        let(:body) { get_message_part(mail, /html/) }

        it "should include user's name" do
          body.should match(user.name)
        end

        it "should include user's Class" do
          body.should match(user.class.name)
        end

        it "should include user's username" do
          body.should match(user.username)
        end
      end

      describe "text body" do
        let(:body) { get_message_part(mail, /plain/) }

        it "should include user's name" do
          body.should match(user.name)
        end

        it "should include user's Class" do
          body.should match(user.class.name)
        end

        it "should include user's username" do
          body.should match(user.username)
        end
      end
    end

    context "with Employee" do
      let(:user) { FactoryGirl.create(:employee) }
      let(:mail) { AdminNotificationMailer.new_user(user) }

      it "generates a multipart message (plain text and html)" do
        mail.body.parts.length.should eq(2)
        mail.body.parts.collect(&:content_type).should == ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
      end
        
      it "renders the subject" do
        mail.subject.should eq("You have a new user!")
      end

      it "sends to administrator" do
        mail.to.should eq(["bryce.senz@credda.com"])
      end

      it "sends from no-reply" do
        mail.from.should eq(["no-reply@credda.com"])
      end

      it "has a body" do
        mail.body.should_not be_nil
      end

      describe "HTML body" do
        let(:body) { get_message_part(mail, /html/) }

        it "should include user's name" do
          body.should match(user.name)
        end

        it "should include user's Class" do
          body.should match(user.class.name)
        end

        it "should include user's username" do
          body.should match(user.username)
        end
      end

      describe "text body" do
        let(:body) { get_message_part(mail, /plain/) }

        it "should include user's name" do
          body.should match(user.name)
        end

        it "should include user's Class" do
          body.should match(user.class.name)
        end

        it "should include user's username" do
          body.should match(user.username)
        end
      end
    end
  end

  describe 'authorize_net_error', :authorize_net_error => true do
    context "with Customer" do
      let(:user) { FactoryGirl.create(:customer) }
      let(:error) { StandardError.new("Test Error Message") }
      let(:mail) { AdminNotificationMailer.authorize_net_error(user, error) }

      it "generates a multipart message (plain text and html)" do
        mail.body.parts.length.should eq(2)
        mail.body.parts.collect(&:content_type).should == ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
      end
        
      it "renders the subject" do
        mail.subject.should eq("Authorize.net Error")
      end

      it "sends to administrator" do
        mail.to.should eq(["bryce.senz@credda.com"])
      end

      it "sends from no-reply" do
        mail.from.should eq(["no-reply@credda.com"])
      end

      it "has a body" do
        mail.body.should_not be_nil
      end

      describe "HTML body" do
        let(:body) { get_message_part(mail, /html/) }

        it "should include user's name" do
          body.should match(user.name)
        end

        it "should include user's username" do
          body.should match(user.username)
        end

        it "should include user's email" do
          body.should match(user.email)
        end

        it "should include user's phone number" do
          body.should match(user.phone_number.phone_number)
        end

        it "should include error message" do
          body.should match("Test Error Message")
        end
      end

      describe "text body" do
        let(:body) { get_message_part(mail, /plain/) }

        it "should include user's name" do
          body.should match(user.name)
        end

        it "should include user's username" do
          body.should match(user.username)
        end

        it "should include user's email" do
          body.should match(user.email)
        end

        it "should include user's phone number" do
          body.should match(user.phone_number.phone_number)
        end

        it "should include error message" do
          body.should match("Test Error Message")
        end
      end
    end
  end

  describe 'report_error', :report_error => true do
    let(:model) { "Customer" }
    let(:method) { "name" }
    let(:message) { "Test Error Message" }
    let(:mail) { AdminNotificationMailer.report_error(model, method, message) }

    it "generates a multipart message (plain text and html)" do
      mail.body.parts.length.should eq(2)
      mail.body.parts.collect(&:content_type).should == ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
    end
      
    it "renders the subject" do
      mail.subject.should eq("Application Error")
    end

    it "sends to administrator" do
      mail.to.should eq(["bryce.senz@credda.com"])
    end

    it "sends from no-reply" do
      mail.from.should eq(["no-reply@credda.com"])
    end

    it "has a body" do
      mail.body.should_not be_nil
    end

    describe "HTML body" do
      let(:body) { get_message_part(mail, /html/) }

      it "should include model name" do
        body.should match(model)
      end

      it "should include method" do
        body.should match(method)
      end

      it "should include message" do
        body.should match(message)
      end
    end

    describe "text body" do
      let(:body) { get_message_part(mail, /plain/) }

      it "should include model name" do
        body.should match(model)
      end

      it "should include method" do
        body.should match(method)
      end

      it "should include message" do
        body.should match(message)
      end
    end
  end

  describe 'report_payment', :report_payment => true do
    let(:user) { FactoryGirl.create(:customer) }
    let(:amount) { BigDecimal.new("34.00")}
    let(:mail) { AdminNotificationMailer.report_payment(user, amount) }

    it "generates a multipart message (plain text and html)" do
      mail.body.parts.length.should eq(2)
      mail.body.parts.collect(&:content_type).should == ["text/plain; charset=UTF-8", "text/html; charset=UTF-8"]
    end
      
    it "renders the subject" do
      mail.subject.should eq("New Payment")
    end

    it "sends to administrator" do
      mail.to.should eq(["bryce.senz@credda.com"])
    end

    it "sends from no-reply" do
      mail.from.should eq(["no-reply@credda.com"])
    end

    it "has a body" do
      mail.body.should_not be_nil
    end

    describe "HTML body" do
      let(:body) { get_message_part(mail, /html/) }

      it "should include user name" do
        body.should match(user.name)
      end

      it "should include user username" do
        body.should match(user.username)
      end

      it "should include amount" do
        body.should match("34")
      end
    end

    describe "text body" do
      let(:body) { get_message_part(mail, /plain/) }

      it "should include user name" do
        body.should match(user.name)
      end

      it "should include user username" do
        body.should match(user.username)
      end

      it "should include amount" do
        body.should match("34")
      end
    end
  end
end