require 'spec_helper'

describe AuthorizeNetService do
  AUTHORIZE_NET_SUCCESS_CODES =           [:I00001]
  AUTHORIZE_NET_PROCESSING_ERROR_CODES =  [:E00001]
  AUTHORIZE_NET_REQUEST_ERROR_CODES =     [:E00002, :E00003, :E00004, :E00005, :E00006, 
                                           :E00007, :E00008, :E00009, :E00010, :E00011,
                                           :E00044, :E00045, :E00051]
  AUTHORIZE_NET_DATA_ERROR_CODES =        [:E00013, :E00014, :E00015, :E00016, :E00019, 
                                           :E00029, :E00039, :E00040, :E00041, :E00042, 
                                           :E00043]
  AUTHORIZE_NET_TRANSACTION_ERROR_CODES = [:E00027]

  # Service Initializer
  #----------------------------------------------------------------------------
  describe "AuthorizeNetService", :failing => true do
    #TODO: Write tests for setup
  end

  # Customer Profile Methods
  #----------------------------------------------------------------------------
  describe "create_cim_customer_profile", :method => true do
    let(:service) { AuthorizeNetService.new }

    context "without customer" do
      let(:customer) { nil }

      it "returns error" do
        expect{ service.create_cim_customer_profile(customer) }.to raise_error
      end
    end

    context "with invalid model" do
      let(:customer) { FactoryGirl.create(:store) }

      it "returns error" do
        expect{ service.create_cim_customer_profile(customer) }.to raise_error
      end
    end      

    context "with valid customer" do
      let(:customer) { FactoryGirl.create(:customer_no_id)}
      let(:request) {"createCustomerProfileRequest"}

      it "is automatically called" do
        service.create_cim_customer_profile(customer)        
        a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*#{request}.*/).should have_been_made
      end
      
      context "with successful response" do
        AUTHORIZE_NET_SUCCESS_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "populates 'cim_customer_profile_id'" do
                customer.cim_customer_profile_id.should be_nil
                service.create_cim_customer_profile(customer)
                customer.cim_customer_profile_id.should_not be_nil
              end
            end
          end
        end
      end

      context "with processing error" do
        AUTHORIZE_NET_PROCESSING_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.create_cim_customer_profile(customer) }.to raise_error
              end

              it "does not populate 'cim_customer_profile_id'" do
                customer.cim_customer_profile_id.should be_nil
                expect{ service.create_cim_customer_profile(customer) }.to raise_error
                customer.cim_customer_profile_id.should be_nil
              end
            end
          end
        end
      end

      context "with request error" do
        AUTHORIZE_NET_REQUEST_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.create_cim_customer_profile(customer) }.to raise_error
              end

              it "does not populate 'cim_customer_profile_id'" do
                customer.cim_customer_profile_id.should be_nil
                expect{ service.create_cim_customer_profile(customer) }.to raise_error
                customer.cim_customer_profile_id.should be_nil
              end
            end
          end
        end
      end

      context "with data error" do
        AUTHORIZE_NET_DATA_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.create_cim_customer_profile(customer) }.to raise_error
              end

              it "does not populate 'cim_customer_profile_id'" do
                customer.cim_customer_profile_id.should be_nil
                expect{ service.create_cim_customer_profile(customer) }.to raise_error
                customer.cim_customer_profile_id.should be_nil
              end
            end
          end
        end
      end

      context "with transaction error" do
        AUTHORIZE_NET_TRANSACTION_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.create_cim_customer_profile(customer) }.to raise_error
              end

              it "does not populate 'cim_customer_profile_id'" do
                customer.cim_customer_profile_id.should be_nil
                expect{ service.create_cim_customer_profile(customer) }.to raise_error
                customer.cim_customer_profile_id.should be_nil
              end
            end
          end
        end
      end
    end
  end

  describe "get_cim_customer_profile", :method => true do
    let(:service) { AuthorizeNetService.new }

    context "without customer" do
      let(:customer) { nil }

      it "returns error" do
        expect{ service.get_cim_customer_profile(customer) }.to raise_error
      end
    end

    context "with invalid model" do
      let(:customer) { FactoryGirl.create(:store) }

      it "returns error" do
        expect{ service.get_cim_customer_profile(customer) }.to raise_error
      end
    end      

    context "with valid customer" do
      context "without cim_customer_profile_id" do
        let(:customer) { FactoryGirl.create(:customer_no_id)}

        it "returns error" do
          expect{ service.get_cim_customer_profile(customer) }.to raise_error
        end
      end
      
      context "with cim_customer_profile_id" do
        let(:customer) do
          customer = FactoryGirl.create(:customer)
        end
        let(:request) {"getCustomerProfileRequest"}

        it "is automatically called" do
          service.get_cim_customer_profile(customer)        
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*#{request}.*/).should have_been_made
        end

        context "with successful response" do
          AUTHORIZE_NET_SUCCESS_CODES.each do |response|
            describe "on request" do
              before(:each) do
                webmock_authorize_net(request, response)
              end
  
              context "with response #{response}" do
                it "returns Hash of profile details" do
                  profile = service.get_cim_customer_profile(customer)
                  profile.is_a?(Hash).should be_true
                end
              end
            end
          end
        end

        context "with processing error" do
          AUTHORIZE_NET_PROCESSING_ERROR_CODES.each do |response|
            describe "on request" do
              before(:each) do
                webmock_authorize_net(request, response)
              end
  
              context "with response #{response}" do
                it "raises error" do
                  expect{ service.get_cim_customer_profile(customer) }.to raise_error
                end
              end
            end
          end
        end

        context "with request error" do
          AUTHORIZE_NET_REQUEST_ERROR_CODES.each do |response|
            describe "on request" do
              before(:each) do
                webmock_authorize_net(request, response)
              end
  
              context "with response #{response}" do
                it "raises error" do
                  expect{ service.get_cim_customer_profile(customer) }.to raise_error
                end
              end
            end
          end
        end

        context "with data error" do
          AUTHORIZE_NET_DATA_ERROR_CODES.each do |response|
            describe "on request" do
              before(:each) do
                webmock_authorize_net(request, response)
              end
  
              context "with response #{response}" do
                it "raises error" do
                  expect{ service.get_cim_customer_profile(customer) }.to raise_error
                end
              end
            end
          end
        end
  
        context "with transaction error" do
          AUTHORIZE_NET_TRANSACTION_ERROR_CODES.each do |response|
            describe "on request" do
              before(:each) do
                webmock_authorize_net(request, response)
              end
  
              context "with response #{response}" do
                it "raises error" do
                  expect{ service.get_cim_customer_profile(customer) }.to raise_error
                end
              end
            end
          end
        end
      end
    end
  end

  describe "update_cim_customer_profile", :method => true do
    let(:service) { AuthorizeNetService.new }

    context "without customer" do
      let(:customer) { nil }

      it "returns error" do
        expect{ service.update_cim_customer_profile(customer) }.to raise_error
      end
    end

    context "with invalid model" do
      let(:customer) { FactoryGirl.create(:store) }

      it "returns error" do
        expect{ service.update_cim_customer_profile(customer) }.to raise_error
      end
    end      

    context "with valid customer" do
      context "without cim_customer_profile_id" do
        let(:customer) { FactoryGirl.create(:customer_no_id)}

        it "returns error" do
          expect{ service.update_cim_customer_profile(customer) }.to raise_error
        end
      end
      
      context "with cim_customer_profile_id" do
        let(:customer) do
          customer = FactoryGirl.create(:customer)
        end
        let(:request) {"updateCustomerProfileRequest"}

        it "is automatically called" do
          service.update_cim_customer_profile(customer)        
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*#{request}.*/).should have_been_made
        end

        context "with successful response" do
          AUTHORIZE_NET_SUCCESS_CODES.each do |response|
            describe "on request" do
              before(:each) do
                webmock_authorize_net(request, response)
              end
  
              context "with response #{response}" do
                it "returns true" do
                  service.update_cim_customer_profile(customer).should be_true
                end
              end
            end
          end
        end

        context "with processing error" do
          AUTHORIZE_NET_PROCESSING_ERROR_CODES.each do |response|
            describe "on request" do
              before(:each) do
                webmock_authorize_net(request, response)
              end
  
              context "with response #{response}" do
                it "raises error" do
                  expect{ service.update_cim_customer_profile(customer) }.to raise_error
                end
              end
            end
          end
        end

        context "with request error" do
          AUTHORIZE_NET_REQUEST_ERROR_CODES.each do |response|
            describe "on request" do
              before(:each) do
                webmock_authorize_net(request, response)
              end
  
              context "with response #{response}" do
                it "raises error" do
                  expect{ service.update_cim_customer_profile(customer) }.to raise_error
                end
              end
            end
          end
        end

        context "with data error" do
          AUTHORIZE_NET_DATA_ERROR_CODES.each do |response|
            describe "on request" do
              before(:each) do
                webmock_authorize_net(request, response)
              end
  
              context "with response #{response}" do
                it "raises error" do
                  expect{ service.update_cim_customer_profile(customer) }.to raise_error
                end
              end
            end
          end
        end
  
        context "with transaction error" do
          AUTHORIZE_NET_TRANSACTION_ERROR_CODES.each do |response|
            describe "on request" do
              before(:each) do
                webmock_authorize_net(request, response)
              end
  
              context "with response #{response}" do
                it "raises error" do
                  expect{ service.update_cim_customer_profile(customer) }.to raise_error
                end
              end
            end
          end
        end
      end
    end
  end

  describe "delete_cim_customer_profile", :method => true do
    let(:service) { AuthorizeNetService.new }

    context "without customer" do
      let(:customer) { nil }

      it "returns error" do
        expect{ service.create_cim_customer_profile(customer) }.to raise_error
      end
    end

    context "with invalid model" do
      let(:customer) { FactoryGirl.create(:store) }

      it "returns error" do
        expect{ service.create_cim_customer_profile(customer) }.to raise_error
      end
    end      

    context "with valid customer" do
      let(:request) {"deleteCustomerProfileRequest"}

      context "without cim_customer_profile_id" do
        let(:customer) { FactoryGirl.create(:customer_no_id)}

        it "returns error" do
          customer.cim_customer_profile_id.should be_nil
          expect{ service.delete_cim_customer_profile(customer) }.to raise_error
        end
      end
  
      context "with cim_customer_profile_id" do
        let(:customer) { FactoryGirl.create(:customer)}

        it "is automatically called" do
          service.delete_cim_customer_profile(customer)        
          a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*#{request}.*/).should have_been_made
        end

        context "with successful response" do
          AUTHORIZE_NET_SUCCESS_CODES.each do |response|
            describe "on request" do
              before(:each) do
                webmock_authorize_net(request, response)
              end
  
              context "with response #{response}" do
                it "returns true" do
                  service.delete_cim_customer_profile(customer).should be_true
                end
              end
            end
          end
        end
      end
      
      context "with request error" do
        AUTHORIZE_NET_REQUEST_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.delete_cim_customer_profile(customer) }.to raise_error
              end
            end
          end
        end
      end

      context "with data error" do
        AUTHORIZE_NET_DATA_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.delete_cim_customer_profile(customer) }.to raise_error
              end
            end
          end
        end
      end

      context "with transaction error" do
        AUTHORIZE_NET_TRANSACTION_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.delete_cim_customer_profile(customer) }.to raise_error
              end
            end
          end
        end
      end
    end
  end

  # Customer Payment Profile Methods
  #----------------------------------------------------------------------------
  describe "create_cim_customer_payment_profile", :method => true do
    let(:service) { AuthorizeNetService.new }
    
    context "as bank account" do
      context "without payment_profile" do
        let(:payment_profile) { nil }
  
        it "returns error" do
          expect{ service.create_cim_customer_payment_profile(payment_profile) }.to raise_error
        end
      end

      context "with invalid model" do
        let(:payment_profile) { FactoryGirl.create(:store) }
  
        it "returns error" do
          expect{ service.create_cim_customer_payment_profile(payment_profile) }.to raise_error
        end
      end

      context "with valid payment_profile" do
        let(:request) {"createCustomerPaymentProfileRequest"}
  
        context "without cim_customer_profile_id" do
          let(:customer) { FactoryGirl.create(:customer_no_id)}
          let(:payment_profile) { FactoryGirl.create(:bank_account_payment_profile, :customer => customer) }
  
          it "returns error" do
            customer.cim_customer_profile_id.should be_nil
            expect{ service.create_cim_customer_payment_profile(payment_profile) }.to raise_error
          end
        end
    
        context "with cim_customer_profile_id" do
          let(:payment_profile) { FactoryGirl.create(:bank_account_payment_profile) }
  
          it "is automatically called" do
            service.create_cim_customer_payment_profile(payment_profile)
            a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*#{request}.*/).should have_been_made
          end
  
          context "with successful response" do
            AUTHORIZE_NET_SUCCESS_CODES.each do |response|
              describe "on request" do
                before(:each) do
                  webmock_authorize_net(request, response)
                end
    
                context "with response #{response}" do
                  it "returns true" do
                    service.create_cim_customer_payment_profile(payment_profile).should be_true
                  end
                end
              end
            end
          end

          context "with request error" do
            AUTHORIZE_NET_REQUEST_ERROR_CODES.each do |response|
              describe "on request" do
                before(:each) do
                  webmock_authorize_net(request, response)
                end
    
                context "with response #{response}" do
                  it "raises error" do
                    expect{ service.create_cim_customer_payment_profile(payment_profile) }.to raise_error
                  end
                end
              end
            end
          end
    
          context "with data error" do
            AUTHORIZE_NET_DATA_ERROR_CODES.each do |response|
              describe "on request" do
                before(:each) do
                  webmock_authorize_net(request, response)
                end
    
                context "with response #{response}" do
                  it "raises error" do
                    expect{ service.create_cim_customer_payment_profile(payment_profile) }.to raise_error
                  end
                end
              end
            end
          end

          context "with transaction error" do
            AUTHORIZE_NET_TRANSACTION_ERROR_CODES.each do |response|
              describe "on request" do
                before(:each) do
                  webmock_authorize_net(request, response)
                end
    
                context "with response #{response}" do
                  it "raises error" do
                    expect{ service.create_cim_customer_payment_profile(payment_profile) }.to raise_error
                  end
                end
              end
            end
          end
        end
      end
    end

    context "as credit_card" do
      context "without payment_profile" do
        let(:payment_profile) { nil }
  
        it "returns error" do
          expect{ service.create_cim_customer_payment_profile(payment_profile) }.to raise_error
        end
      end

      context "with invalid model" do
        let(:payment_profile) { FactoryGirl.create(:store) }
  
        it "returns error" do
          expect{ service.create_cim_customer_payment_profile(payment_profile) }.to raise_error
        end
      end

      context "with valid payment_profile" do
        let(:request) {"createCustomerPaymentProfileRequest"}
  
        context "without cim_customer_profile_id" do
          let(:customer) { FactoryGirl.create(:customer_no_id)}
          let(:payment_profile) { FactoryGirl.create(:credit_card_payment_profile, :customer => customer) }
  
          it "returns error" do
            customer.cim_customer_profile_id.should be_nil
            expect{ service.create_cim_customer_payment_profile(payment_profile) }.to raise_error
          end
        end
    
        context "with cim_customer_profile_id" do
          let(:payment_profile) { FactoryGirl.create(:credit_card_payment_profile) }
  
          it "is automatically called" do
            service.create_cim_customer_payment_profile(payment_profile)
            a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*#{request}.*/).should have_been_made
          end
  
          context "with successful response" do
            AUTHORIZE_NET_SUCCESS_CODES.each do |response|
              describe "on request" do
                before(:each) do
                  webmock_authorize_net(request, response)
                end
    
                context "with response #{response}" do
                  it "returns true" do
                    service.create_cim_customer_payment_profile(payment_profile).should be_true
                  end
                end
              end
            end
          end

          context "with request error" do
            AUTHORIZE_NET_REQUEST_ERROR_CODES.each do |response|
              describe "on request" do
                before(:each) do
                  webmock_authorize_net(request, response)
                end
    
                context "with response #{response}" do
                  it "raises error" do
                    expect{ service.create_cim_customer_payment_profile(payment_profile) }.to raise_error
                  end
                end
              end
            end
          end
    
          context "with data error" do
            AUTHORIZE_NET_DATA_ERROR_CODES.each do |response|
              describe "on request" do
                before(:each) do
                  webmock_authorize_net(request, response)
                end
    
                context "with response #{response}" do
                  it "raises error" do
                    expect{ service.create_cim_customer_payment_profile(payment_profile) }.to raise_error
                  end
                end
              end
            end
          end

          context "with transaction error" do
            AUTHORIZE_NET_TRANSACTION_ERROR_CODES.each do |response|
              describe "on request" do
                before(:each) do
                  webmock_authorize_net(request, response)
                end
    
                context "with response #{response}" do
                  it "raises error" do
                    expect{ service.create_cim_customer_payment_profile(payment_profile) }.to raise_error
                  end
                end
              end
            end
          end
        end  
      end
    end
  end

  describe "get_cim_customer_payment_profile", :method => true do
    let(:service) { AuthorizeNetService.new }
    
    context "without payment_profile" do
      let(:payment_profile) { nil }

      it "returns error" do
        expect{ service.get_cim_customer_payment_profile(payment_profile) }.to raise_error
      end
    end

    context "with invalid model" do
      let(:payment_profile) { FactoryGirl.create(:store) }

      it "returns error" do
        expect{ service.get_cim_customer_payment_profile(payment_profile) }.to raise_error
      end
    end

    context "with valid payment_profile" do
      let(:request) {"getCustomerPaymentProfileRequest"}
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }

      it "is automatically called", :failing => true do
        service.get_cim_customer_payment_profile(payment_profile)
        a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*#{request}.*/).should have_been_made
      end

      context "with successful response" do
        AUTHORIZE_NET_SUCCESS_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "returns true" do
                response = service.get_cim_customer_payment_profile(payment_profile)
                response.is_a?(Hash).should be_true
              end
            end
          end
        end
      end

      context "with request error" do
        AUTHORIZE_NET_REQUEST_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.get_cim_customer_payment_profile(payment_profile) }.to raise_error
              end
            end
          end
        end
      end

      context "with data error" do
        AUTHORIZE_NET_DATA_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.get_cim_customer_payment_profile(payment_profile) }.to raise_error
              end
            end
          end
        end
      end

      context "with transaction error" do
        AUTHORIZE_NET_TRANSACTION_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.get_cim_customer_payment_profile(payment_profile) }.to raise_error
              end
            end
          end
        end
      end
    end
  end

  describe "update_cim_customer_payment_profile", :method => true do
    let(:service) { AuthorizeNetService.new }
    
    context "without payment_profile" do
      let(:payment_profile) { nil }

      it "returns error" do
        expect{ service.update_cim_customer_payment_profile(payment_profile) }.to raise_error
      end
    end

    context "with invalid model" do
      let(:payment_profile) { FactoryGirl.create(:store) }

      it "returns error" do
        expect{ service.update_cim_customer_payment_profile(payment_profile) }.to raise_error
      end
    end

    context "with valid payment_profile" do
      let(:request) {"updateCustomerPaymentProfileRequest"}
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }

      it "is automatically called" do
        service.update_cim_customer_payment_profile(payment_profile)
        a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*#{request}.*/).should have_been_made
      end

      context "with successful response" do
        AUTHORIZE_NET_SUCCESS_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "returns true" do
                service.update_cim_customer_payment_profile(payment_profile).should be_true
              end
            end
          end
        end
      end

      context "with request error" do
        AUTHORIZE_NET_REQUEST_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.update_cim_customer_payment_profile(payment_profile) }.to raise_error
              end
            end
          end
        end
      end

      context "with data error" do
        AUTHORIZE_NET_DATA_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.update_cim_customer_payment_profile(payment_profile) }.to raise_error
              end
            end
          end
        end
      end

      context "with transaction error" do
        AUTHORIZE_NET_TRANSACTION_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.update_cim_customer_payment_profile(payment_profile) }.to raise_error
              end
            end
          end
        end
      end
    end
  end

  describe "delete_cim_customer_payment_profile", :method => true do
    let(:service) { AuthorizeNetService.new }
    
    context "without payment_profile" do
      let(:payment_profile) { nil }

      it "returns error" do
        expect{ service.delete_cim_customer_payment_profile(payment_profile) }.to raise_error
      end
    end

    context "with invalid model" do
      let(:payment_profile) { FactoryGirl.create(:store) }

      it "returns error" do
        expect{ service.delete_cim_customer_payment_profile(payment_profile) }.to raise_error
      end
    end

    context "with valid payment_profile" do
      let(:request) {"deleteCustomerPaymentProfileRequest"}
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }

      it "is automatically called" do
        service.delete_cim_customer_payment_profile(payment_profile)
        a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*#{request}.*/).should have_been_made
      end

      context "with successful response" do
        AUTHORIZE_NET_SUCCESS_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "returns true" do
                service.delete_cim_customer_payment_profile(payment_profile).should be_true
              end
            end
          end
        end
      end

      context "with request error" do
        AUTHORIZE_NET_REQUEST_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.delete_cim_customer_payment_profile(payment_profile) }.to raise_error
              end
            end
          end
        end
      end

      context "with data error" do
        AUTHORIZE_NET_DATA_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.delete_cim_customer_payment_profile(payment_profile) }.to raise_error
              end
            end
          end
        end
      end

      context "with transaction error" do
        AUTHORIZE_NET_TRANSACTION_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.delete_cim_customer_payment_profile(payment_profile) }.to raise_error
              end
            end
          end
        end
      end
    end
  end

  # Customer Payment Profile Methods
  #----------------------------------------------------------------------------
  describe "create_cim_customer_profile_transaction", :method => true do
    let(:service) { AuthorizeNetService.new }
    
    context "without payment_profile" do
      let(:payment_profile) { nil }
      let(:amount) { BigDecimal.new("10") }

      it "returns error" do
        expect{ service.create_cim_customer_profile_transaction(payment_profile, amount) }.to raise_error
      end
    end

    context "with invalid model" do
      let(:payment_profile) { FactoryGirl.create(:store) }
      let(:amount) { BigDecimal.new("10") }

      it "returns error" do
        expect{ service.create_cim_customer_profile_transaction(payment_profile, amount) }.to raise_error
      end
    end

    context "with valid payment_profile" do
      let(:request) {"createCustomerProfileTransactionRequest"}
      let(:payment_profile) { FactoryGirl.create(:payment_profile) }
      let(:amount) { BigDecimal.new("10") }

      it "is automatically called" do
        service.create_cim_customer_profile_transaction(payment_profile, amount)
        a_request(:post, /https:\/\/apitest.authorize.net\/xml\/v1\/request.api.*/).with(:body => /.*#{request}.*/).should have_been_made
      end

      context "with successful response" do
        AUTHORIZE_NET_SUCCESS_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "returns true" do
                service.create_cim_customer_profile_transaction(payment_profile, amount).should be_true
              end
            end
          end
        end
      end

      context "with request error" do
        AUTHORIZE_NET_REQUEST_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.create_cim_customer_profile_transaction(payment_profile, amount) }.to raise_error
              end
            end
          end
        end
      end

      context "with data error" do
        AUTHORIZE_NET_DATA_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.create_cim_customer_profile_transaction(payment_profile, amount) }.to raise_error
              end
            end
          end
        end
      end

      context "with transaction error" do
        AUTHORIZE_NET_TRANSACTION_ERROR_CODES.each do |response|
          describe "on request" do
            before(:each) do
              webmock_authorize_net(request, response)
            end

            context "with response #{response}" do
              it "raises error" do
                expect{ service.create_cim_customer_profile_transaction(payment_profile, amount) }.to raise_error
              end
            end
          end
        end
      end
    end
  end
end