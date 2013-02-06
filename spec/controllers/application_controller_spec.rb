require 'spec_helper'

describe ApplicationController do
  #Base class should be inferred  
  controller do
    def not_found
      raise ActiveRecord::RecordNotFound
    end
    
    def denied
#      raise CanCan::AccessDenied
    end
  end

  # Error Handling
  #----------------------------------------------------------------------------
  def with_error_routing
    with_routing do |map|
      map.draw do
        get '/not_found' => "anonymous#not_found",     :as => :not_found
        get '/denied'    => "anonymous#denied",        :as => :denied
      end
      yield
    end
  end

  describe "handling ActiveRecord::RecordNotFound" do
    it "renders the 404 template" do
      with_error_routing do
        get :not_found#, :format => 'html'
        response.should render_template 'error/404'
      end
    end

    it "sets flash warning" do
      with_error_routing do
        get :not_found, :format => 'html'
        flash[:warning].should =~ /Oops, we couldn't find that./
      end
    end
  end

  describe "handling CanCan::AccessDenied" do
    it "renders the 403 template" do
      with_error_routing do
        get :denied, :format => 'html'
        response.should render_template 'error/403'
      end
    end

    it "sets flash warning" do
      with_error_routing do
        get :denied, :format => 'html'
        flash[:warning].should =~ /Hey! You're not allowed back here!/
      end
    end
  end
  
  # Current Ability
  #----------------------------------------------------------------------------
  describe "current ability" do
#    specify { subject.current_ability.should_not be_nil }
#    specify { subject.current_ability.should be_a(AnonymousAbility) }  
  end
  
  describe "current user" do
    context "as anonymous user" do
      include_context "as anonymous"
      specify { subject.current_store.should be_nil }
      specify { subject.current_customer.should be_nil }  
    end

    context "as store" do
      include_context "as store"
      specify { subject.current_store.should_not be_nil }
      specify { subject.current_customer.should be_nil }  
    end

    context "as customer" do
      include_context "as customer"
      specify { subject.current_store.should be_nil }
      specify { subject.current_customer.should_not be_nil }  
    end
  end
end