require 'spec_helper'
require 'cancan'
require 'cancan/matchers'
=begin
describe Customer::RegistrationsController do
  include Devise::TestHelpers

  def do_get_new( format = 'html' )
    get :new, :format => format
  end

  def do_post_create( format = 'html', attributes = FactoryGirl.attributes_for(:customer) )
    post :create, :customer => attributes, :format => format
  end

  def do_post_create_invalid( format = 'html', attributes = FactoryGirl.attributes_for(:customer, email: "invalid.fail.com") )
    post :create, :user => attributes, :format => format
  end
 
  context "As an anonymous customer" do
    let(:customer) do
      FactoryGirl.build(:customer)
    end
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:customer]
      customer.confirm!
    end

    it "does not have a current user" do
      subject.current_user.should be_nil
    end

    describe "#new" do
      it "can access the sign-up page" do
        do_get_new
        response.should be_success
      end
    end

    describe "#create" do
      context "with valid attributes" do
        it "can register as a new user" do
          expect{
            do_post_create
          }.to change(Customer,:count).by(1)
        end
        
        it "is signed in after registration" do
          do_post_create
          subject.current_customer.should_not be_nil
        end
      end
      
      context "with invalid attributes" do
        it "cannot register" do
          expect{
            do_post_create_invalid
          }.to_not change(Customer,:count)
        end
      end
    end
  end
  
  context "As an authenticated customer" do
    let(:customer) do
      FactoryGirl.create(:customer)
    end
    before { 
      @request.env["devise.mapping"] = Devise.mappings[:customer]
      sign_in customer
    }
    
    describe "#new" do
      it "is re-directed away from the sign-up page" do
        do_get_new
        response.code.should eq("302")
      end
    end
    
    describe "#create" do
      context "with valid attributes" do
        it "cannot register a new user" do
          expect{
            do_post_create
          }.to_not change(Customer,:count)
        end
      end
      context "with invalid attributes" do
        it "cannot register a new user" do
          expect{
            do_post_create_invalid
          }.to_not change(Customer,:count)
        end
      end
    end
    
    describe "#update" do      
      context "valid attributes" do
        it "located the requested user" do
          put :update, :id => customer, :user => FactoryGirl.attributes_for(:customer)
          assigns(:customer).should eq(customer)
        end
  
        it "changes user's username with no password" do
          customer_attributes = FactoryGirl.attributes_for(:customer, username: "Updated")
          customer_attributes['password'] = nil
          customer_attributes['password_confirmation'] = nil
          customer_attributes['current_password'] = customer.password
          
          put :update, :id => customer, :customer => customer_attributes
          customer.reload
          customer.username.should eq("Updated")
        end
  
        it "changes user's attributes and password" do
          customer_attributes = FactoryGirl.attributes_for(:customer, username: "Updated")
          customer_attributes['current_password'] = customer.password
          
          put :update, :id => customer, :customer => customer_attributes
          customer.reload
          customer.username.should eq("Updated")
        end
  
        it "redirects to the updated user" do
          customer_attributes = FactoryGirl.attributes_for(:user, username: "Updated")
          customer_attributes['current_password'] = customer.password
          
          put :update, :id => customer, :customer => customer_attributes
          customer.reload
          customer.username.should eq("Updated")
          response.should redirect_to home_path
        end
      end
  
      context "invalid attributes" do
        it "locates the requested user" do
          put :update, id: customer, customer: FactoryGirl.attributes_for(:invalid_customer)
          assigns(:customer).should eq(customer)
        end
    
        it "does not change user's attributes" do
          original_name = customer.username
          customer_attributes = FactoryGirl.attributes_for(:customer, username: "Updated")
          customer_attributes['current_password'] = "InvalidPass"
          
          put :update, :id => customer, :customer => customer_attributes
          customer.reload
          customer.username.should eq(original_name)
        end
    
        it "re-renders the edit method" do
          customer_attributes = FactoryGirl.attributes_for(:customer, username: "Updated")
          customer_attributes['current_password'] = "InvalidPass"
          
          put :update, :id => customer, :user => customer_attributes
          customer.reload
          response.should render_template :edit
        end
      end      
    end  
  end
end
=end