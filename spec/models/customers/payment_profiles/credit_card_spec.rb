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
      it { should validate_presence_of(:first_name) }
    end

    describe "last_name" do
      it { should validate_presence_of(:last_name) }
    end

    describe "credit_card_number" do
      it { should allow_mass_assignment_of(:credit_card_number) }
      it { should validate_presence_of(:credit_card_number) }

      context "visa" do
        it "allows valid visa values" do
          card = FactoryGirl.build(:visa_credit_card, :credit_card_number => "4111111111111111")
          card.valid?.should be_true
        end

        it "rejects invalid visa values" do
          card = FactoryGirl.build(:visa_credit_card, :credit_card_number => "4111111111111112")
          card.valid?.should be_false
        end
      end

      context "mastercard" do
        it "allows valid mastercard values" do
          card = FactoryGirl.build(:mastercard_credit_card, :credit_card_number => "5555555555554444")
          card.valid?.should be_true
        end

        it "rejects invalid mastercard values" do
          card = FactoryGirl.build(:mastercard_credit_card, :credit_card_number => "4111111111111111")
          card.valid?.should be_false
        end
      end

      context "amex" do
        it "allows valid amex values" do
          card = FactoryGirl.build(:amex_credit_card, :credit_card_number => "371449635398431")
          card.valid?.should be_true
        end

        it "rejects invalid amex values" do
          card = FactoryGirl.build(:amex_credit_card, :credit_card_number => "371449635398432")
          card.valid?.should be_false
        end
      end

      context "discover" do
        it "allows valid discover values" do
          card = FactoryGirl.build(:discover_credit_card, :credit_card_number => "6011111111111117")
          card.valid?.should be_true
        end

        it "rejects invalid discover values" do
          card = FactoryGirl.build(:discover_credit_card, :credit_card_number => "6011111111111118")
          card.valid?.should be_false
        end
      end

      context "diners_club" do
#        it_behaves_like "attr_accessible", :diners_club_credit_card, :credit_card_number,
#          ["30569309025904", "38520000023237"], #Valid values
#          ["30569309025905", "38520000023238", nil] #Invalid values        
      end

      context "jcb" do
#        it_behaves_like "attr_accessible", :jcb_credit_card, :credit_card_number,
#          ["3530111333300000"], #Valid values
#          ["3530111333300001", nil] #Invalid values        
      end
    end

    describe "expiration_date" do
      it { should allow_mass_assignment_of(:expiration_date) }
      it { should validate_presence_of(:expiration_date) }
      it { should allow_value(1.year.from_now, 8.months.from_now).for(:expiration_date) }
      it { should_not allow_value(nil, 1.year.ago).for(:expiration_date) }
    end

    describe "ccv_number" do
      it { should allow_mass_assignment_of(:ccv_number) }
      it { should validate_presence_of(:ccv_number) }
      it { should allow_value("515", "128", "1332").for(:ccv_number) }
      it { should_not allow_value(nil).for(:ccv_number) }
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