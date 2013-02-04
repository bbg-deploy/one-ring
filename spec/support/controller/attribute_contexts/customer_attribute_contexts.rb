module CustomerAttributeContexts
  # Create
  #----------------------------------------------------------------------------
  shared_context "#create customer with valid attributes" do
    let(:model) { Customer }
    let(:factory) { :customer }
    let(:attributes) { FactoryGirl.attributes_for( :customer,
                                     mailing_addresses_attributes: { 
                                       "0" => FactoryGirl.attributes_for(:address).except(:addressable) },
                                     billing_addresses_attributes: { 
                                       "0" => FactoryGirl.attributes_for(:address).except(:addressable) },
                                     phone_numbers_attributes: { 
                                       "0" => FactoryGirl.attributes_for(:phone_number).except(:phonable) } ) }
  end
  shared_context "#create customer with invalid attributes" do
    let(:model) { Customer }
    let(:attributes) { FactoryGirl.attributes_for( :invalid_customer,
                                     mailing_addresses_attributes: { 
                                       "0" => FactoryGirl.attributes_for(:address).except(:addressable) },
                                     billing_addresses_attributes: { 
                                       "0" => FactoryGirl.attributes_for(:address).except(:addressable) },
                                     phone_numbers_attributes: { 
                                       "0" => FactoryGirl.attributes_for(:phone_number).except(:phonable) } ) }
  end
  shared_context "#create customer without mailing address" do
    let(:model) { Customer }
    let(:attributes) { FactoryGirl.attributes_for( :customer,
                                     billing_addresses_attributes: { 
                                       "0" => FactoryGirl.attributes_for(:address).except(:addressable) },
                                     phone_numbers_attributes: { 
                                       "0" => FactoryGirl.attributes_for(:phone_number).except(:phonable) } ) }
  end
  shared_context "#create customer without billing address" do
    let(:model) { Customer }
    let(:attributes) { FactoryGirl.attributes_for( :customer,
                                     mailing_addresses_attributes: { 
                                       "0" => FactoryGirl.attributes_for(:address).except(:addressable) },
                                     phone_numbers_attributes: { 
                                       "0" => FactoryGirl.attributes_for(:phone_number).except(:phonable) } ) }
  end
  shared_context "#create customer without phone number" do
    let(:model) { Customer }
    let(:attributes) { FactoryGirl.attributes_for( :invalid_customer,
                                     mailing_addresses_attributes: { 
                                       "0" => FactoryGirl.attributes_for(:address).except(:addressable) },
                                     billing_addresses_attributes: { 
                                       "0" => FactoryGirl.attributes_for(:address).except(:addressable) } ) }
  end

  # Show
  #----------------------------------------------------------------------------
  shared_context "#show valid customer" do
    let(:model) { Customer }
    let(:object) { FactoryGirl.create(:customer) }
  end
  shared_context "#show invalid customer" do
    let(:model) { Customer }
    let(:object) { FactoryGirl.build(:customer) }
  end

  # Edit
  #----------------------------------------------------------------------------
  shared_context "#edit valid customer" do
    let(:model) { Customer }
    let(:object) { FactoryGirl.create(:customer) }
  end
  shared_context "#edit invalid customer" do
    let(:model) { Customer }
    let(:object) { FactoryGirl.build(:customer) }
  end

  # Update
  #----------------------------------------------------------------------------
  shared_context "#update customer with valid attributes" do
    let(:model) { Customer }
    let(:object) { FactoryGirl.create(:customer) }
    let(:attributes) { { :first_name => "Updated", :last_name => "TestLastname" } }
    let(:attributes) { { :first_name => "Updated", :last_name => "TestLastname" } }
  end
  shared_context "#update customer with invalid attributes" do
    let(:model) { Customer }
    let(:object) { FactoryGirl.create(:customer) }
    let(:attributes) { { :first_name => "Bob!", :email => "invalidemail.com" } }
  end
  shared_context "#update customer email without confirmation" do
    let(:model) { Customer }
    let(:object) { FactoryGirl.create(:customer) }
    let(:attributes) { { :email => "updated@notcredda.com" } }
  end
  shared_context "#update customer password without confirmation" do
    let(:model) { Customer }
    let(:object) { FactoryGirl.create(:customer) }
    let(:attributes) { { :password => "updatedpass" } }
  end

  # Delete
  #----------------------------------------------------------------------------
  shared_context "#delete valid customer" do
    let(:model) { Customer }
    let(:object) { FactoryGirl.create(:customer) }
  end
  shared_context "#delete invalid customer" do
    let(:model) { Customer }
    let(:object) { FactoryGirl.build(:customer) }
  end
end