require 'spec_helper'

describe ApplicationController do
  #Base class should be inferred  
  controller do
    def not_found
      raise ActiveRecord::RecordNotFound
    end
    
    def denied
      raise CanCan::AccessDenied
    end
  end

  # Error Handling
  #----------------------------------------------------------------------------
  def with_error_routing
    with_routing do |map|
      map.draw do
        get '/not_found' => "anonymous#not_found",     :as => :not_found
        get '/denied'    => "anonymous#denied",        :as => :denied
        
        get '/home'      => "anonymous#home",          :as => :home
      end
      yield
    end
  end

  describe "handling ActiveRecord::RecordNotFound" do
    it "renders the 404 template" do
      with_error_routing do
        get :not_found, :format => 'html'
        response.should redirect_to(home_path)
      end
    end

    it "sets flash warning" do
      with_error_routing do
        get :not_found, :format => 'html'
        flash[:alert].should =~ /Oops, we couldn't find that./
      end
    end
  end

  describe "handling CanCan::AccessDenied" do
    it "renders the 403 template" do
      with_error_routing do
        get :denied, :format => 'html'
        response.should redirect_to(home_path)
      end
    end

    it "sets flash warning" do
      with_error_routing do
        get :denied, :format => 'html'
        flash[:alert].should =~ /Access denied/
      end
    end
  end
end