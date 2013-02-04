require 'spec_helper'
require 'cancan'
require 'cancan/matchers'

describe CustomerAbility, :customer => true, :ability => true do
  let(:customer) { FactoryGirl.create(:customer) }
  let(:ability) { CustomerAbility.new(customer) }

  context "on Admins" do
    it_should_behave_like "CRUD restricted", Admin
  end
  context "on AdminRoles" do
    it_should_behave_like "CRUD restricted", AdminRole
  end
  context "on Agents" do
    it_should_behave_like "CRUD restricted", Agent
  end
  context "on AgentRoles" do
    it_should_behave_like "CRUD restricted", AgentRole
  end
  context "on Stores" do
    it_should_behave_like "CRUD restricted", Store
  end
  context "on Customers" do
    it_should_behave_like "CRUD restricted", Customer
    specify { ability.should be_able_to(:read, customer) }
    specify { ability.should be_able_to(:update, customer) }
  end  
end