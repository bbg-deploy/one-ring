require 'spec_helper'
require 'cancan'
require 'cancan/matchers'

describe StoreAbility, :store => true, :ability => true do
  let(:store) { FactoryGirl.create(:store) }
  let(:ability) { StoreAbility.new(store) }

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
    specify { ability.should be_able_to(:read, store) }
    specify { ability.should be_able_to(:update, store) }
  end
  context "on Customers" do
    it_should_behave_like "CRUD restricted", Customer
  end  
end