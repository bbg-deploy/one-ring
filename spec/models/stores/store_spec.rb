require 'spec_helper'

describe Store, :store => true do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { Store.new.should be_an_instance_of(Store) }


    describe "store factory" do
      it_behaves_like "valid record", :store
      
      it "should have phone numbers" do
        store = FactoryGirl.create(:store)
        store.phone_numbers.should_not be_empty
      end

      it "should have addresses" do
        store = FactoryGirl.create(:store)
        store.addresses.should_not be_empty
      end
    end

    describe "invalid_store factory" do
      it_behaves_like "invalid record", :invalid_store
    end

  end
  
  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do    
    describe "addresses" do
      describe "validates nested attributes" do
        specify { expect { FactoryGirl.create(:store, :address_factory => :invalid_address) }.to raise_error }
      end
  
      describe "required association" do
        it_behaves_like "required association" do
          let(:factory) { :store }
          let(:nested_attribute_modifier) { :number_of_addresses }
        end
      end

      describe "dependent destroy", :dependent_destroy => true do
        let(:store) { FactoryGirl.create(:store) }
        it_behaves_like "dependent destroy", :store, :addresses
      end
    end
  
    describe "phone_numbers", :failing => true do
      describe "validates nested attributes" do
        specify { expect { FactoryGirl.create(:store, :phone_number_factory => :invalid_phone_number) }.to raise_error }
      end
  
      describe "required association" do
        it_behaves_like "required association" do
          let(:factory) { :store }
          let(:nested_attribute_modifier) { :number_of_phone_numbers }
        end
      end
  
      describe "dependent destroy", :dependent_destroy => true do
        let(:store) { FactoryGirl.create(:store) }
        it_behaves_like "dependent destroy", :store, :phone_numbers
      end
    end
  end
  
  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do
    # This performs the standard checks for usernames, emails, passwords, etc.
    it_behaves_like "devise attributes (non-employee)", :store

    describe "name" do
      it_behaves_like "attr_accessible", :store, :name,
        ["Credda", "Google", "123Web Services"],  #Valid values
        [nil] #Invalid values
    end

    describe "EIN" do
      it_behaves_like "attr_accessible", :store, :employer_identification_number,
        ["107331121", "10-7331121"],  #Valid values
        [nil, "73311112", "7331111222", "00-1111111", "10-0000000", "07-7654320"] #Invalid values
    end  
  end
  
  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "authentication", :authentication => true do
      it_behaves_like "devise authenticatable", :store do
        # Authentication Configuration
        let(:case_insensitive_keys) { [:email] }
        let(:strip_whitespace_keys) { [:email] }
        let(:authentication_keys) { [:login] }
      end
      
      it_behaves_like "devise recoverable", :store do
        # Recoverable Configuration
        let(:reset_password_keys) { [:email] }
        let(:reset_password_within) { 6.hours }
      end
  
      it_behaves_like "devise lockable", :store do
        # Lockable Configuration
        let(:unlock_keys) { [:email] }
        let(:unlock_strategy) { :both }
        let(:maximum_attempts) { 10 }
        let(:unlock_in) { 1.hour }
      end
  
      it_behaves_like "devise rememberable", :store do
        # Rememberable Configuration
        let(:remember_for) { 2.weeks }
      end
  
      it_behaves_like "devise timeoutable", :store do
        # Timeoutable Configuration
        let(:timeout_in) { 30.minutes }
      end
  
      it_behaves_like "devise confirmable", :store do
        # Confirmable Configuration
        let(:reconfirmable) { true }
        let(:confirmation_keys) { [:email] }
      end
    end
  end
end