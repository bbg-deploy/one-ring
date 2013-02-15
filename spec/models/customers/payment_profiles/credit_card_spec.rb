require 'spec_helper'

describe CreditCard do
  # Model & Factory Validation
  #----------------------------------------------------------------------------
  describe "factory validation", :factory_validation => true do
    specify { CreditCard.new.should be_an_instance_of(CreditCard) }

    describe "credit_card factory" do
      it_behaves_like "valid record", :credit_card
    end
    
    describe "visa_credit_card factory" do
      it_behaves_like "valid record", :visa_credit_card
    end

    describe "mastercard_credit_card factory" do
      it_behaves_like "valid record", :mastercard_credit_card
    end

    describe "amex_credit_card factory", :failing => true do
      it_behaves_like "valid record", :amex_credit_card
    end

    describe "discover_credit_card factory" do
      it_behaves_like "valid record", :discover_credit_card
    end

    describe "diners_club_credit_card factory" do
      it_behaves_like "valid record", :diners_club_credit_card
    end

    describe "jcb_credit_card factory" do
      it_behaves_like "valid record", :jcb_credit_card
    end

    describe "invalid_credit_card factory" do
      it_behaves_like "invalid record", :invalid_credit_card
    end

    describe "credit_card_attributes_hash" do
      it "creates new credit_card when passed to CreditCard" do
        attributes = FactoryGirl.build(:credit_card_attributes_hash)
        credit_card = CreditCard.create!(attributes)
        credit_card.should be_valid
      end
    end
  end
 
  # Associations
  #----------------------------------------------------------------------------
  describe "associations", :associations => true do
    describe "payment_profile" do
      it_behaves_like "required belongs_to", :credit_card, :payment_profile
    end
  end

  # Attributes
  #----------------------------------------------------------------------------
  describe "attributes", :attributes => true do  
    describe "first_name" do
    end

    describe "last_name" do
    end

    describe "credit_card_number" do
      context "visa" do
        it_behaves_like "attr_accessible", :visa_credit_card, :credit_card_number,
          ["4111111111111111"], #Valid values
          ["4111111111111112", nil] #Invalid values        
      end

      context "mastercard" do
        it_behaves_like "attr_accessible", :mastercard_credit_card, :credit_card_number,
          ["5555555555554444", "5105105105105100"], #Valid values
          ["5555555555554443", "5105105105105101", nil] #Invalid values        
      end

      context "amex" do
        it_behaves_like "attr_accessible", :amex_credit_card, :credit_card_number,
          ["378282246310005", "371449635398431"], #Valid values
          ["378282246310006", "371449635398432", nil] #Invalid values        
      end

      context "discover" do
        it_behaves_like "attr_accessible", :discover_credit_card, :credit_card_number,
          ["6011111111111117", "6011000990139424"], #Valid values
          ["6011111111111118", "6011000990139425", nil] #Invalid values        
      end

      context "diners_club" do
        it_behaves_like "attr_accessible", :diners_club_credit_card, :credit_card_number,
          ["30569309025904", "38520000023237"], #Valid values
          ["30569309025905", "38520000023238", nil] #Invalid values        
      end

      context "jcb" do
        it_behaves_like "attr_accessible", :jcb_credit_card, :credit_card_number,
          ["3530111333300000"], #Valid values
          ["3530111333300001", nil] #Invalid values        
      end
    end

    describe "expiration_date" do
      it_behaves_like "attr_accessible", :credit_card, :expiration_date,
        [1.year.from_now, 8.months.from_now], #Valid values
        [1.year.ago, nil] #Invalid values
    end

    describe "ccv_number" do
      it_behaves_like "attr_accessible", :credit_card, :ccv_number,
        ["513", "128"], #Valid values
        [nil] #Invalid values
    end
  end

  # Behavior
  #----------------------------------------------------------------------------
  describe "behavior", :behavior => true do
    describe "authorize_net_format" do
      let(:credit_card) { FactoryGirl.create(:credit_card) }
      
      it "returns Authorize.net card" do
        card = credit_card.card_format
        card.is_a?(ActiveMerchant::Billing::CreditCard).should be_true
      end
    end

    describe "authorize_net_format" do
      let(:credit_card) { FactoryGirl.create(:credit_card) }
      
      it "returns Authorize.net card" do
        card = credit_card.authorize_net_format
        card.is_a?(Hash).should be_true
      end
    end
  end
end