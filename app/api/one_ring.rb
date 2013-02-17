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

      def current_customer
        warden.customer
      end
    end

    desc "Customer Namespace"
    namespace :customer do
      before do
        authenticate_customer!
      end      

      desc "Retrieve a user's status."

      get :home do
        return "Successfully authenticated."
      end
    end

    resource :statuses do
=begin
      desc "Return a public timeline."
      get :public_timeline do
        Status.limit(20)
      end
      desc "Return a personal timeline."
      get :home_timeline do
        authenticate!
        current_user.statuses.limit(20)
      end

      desc "Return a status."
      params do
        requires :id, :type => Integer, :desc => "Status id."
      end
      get ':id' do
        Status.find(params[:id])
      end

      desc "Create a status."
      params do
        requires :status, :type => String, :desc => "Your status."
      end
      post do
        authenticate!
        Status.create!({
          :user => current_user,
          :text => params[:status]
        })
      end

      desc "Update a status."
      params do
        requires :id, :type => String, :desc => "Status ID."
        requires :status, :type => String, :desc => "Your status."
      end
      put ':id' do
        authenticate!
        current_user.statuses.find(params[:id]).update({
          :user => current_user,
          :text => params[:status]
        })
      end

      desc "Delete a status."
      params do
        requires :id, :type => String, :desc => "Status ID."
      end
      delete ':id' do
        authenticate!
        current_user.statuses.find(params[:id]).destroy
      end
=end
    end
  end
end