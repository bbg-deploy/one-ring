module OneRing
  class APIv1 < Grape::API
    prefix 'api'
    version 'v1', :using => :path
    format :json

    helpers do
      def warden
        env['warden']
      end

      def authenticate_customer!
        error!('401 Unauthorized', 401) unless warden.authenticated?(:customer)
      end

      def authenticate_store!
        error!('401 Unauthorized', 401) unless warden.authenticated?(:store)
      end

      def authenticate_employee!
        error!('401 Unauthorized', 401) unless warden.authenticated?(:employee)
      end

      def current_customer
        warden.customer
      end

      def current_store
        warden.store
      end

      def current_employee
        warden.employee
      end
    end

    desc "Customer Namespace"
    namespace :customer do
      before do
        authenticate_customer!
      end      

      desc "Check authentication."
      # Test Verification
      get :home do
        return "Successfully authenticated."
      end

      # Authentication Actions
      desc "Logout Customer."
      delete :logout do
        warden.logout
      end

      # Payment Profiles
      
    end

    desc "Store Namespace"
    namespace :store do
      before do
        authenticate_store!
      end      

      desc "Check authentication."
      get :home do
        return "Successfully authenticated."
      end      
    end

    desc "Employee Namespace"
    namespace :employee do
      before do
        authenticate_employee!
      end      

      desc "Check authentication."
      get :home do
        return "Successfully authenticated."
      end
    end
  end
end