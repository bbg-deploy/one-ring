require 'spec_helper'
require 'cancan'
require 'cancan/matchers'

describe AdminAbility, :admin => true, :ability => true do
  let(:admin) { FactoryGirl.create(:admin) }
  let(:ability) { AdminAbility.new(admin) }

  context "on Admins" do
    it_should_behave_like "CRUD restricted", Admin
    specify { ability.should be_able_to(:read, admin) }
    specify { ability.should be_able_to(:update, admin) }
  end
  context "on AdminRoles" do
    it_should_behave_like "CRUD allowed", AdminRole
  end
  context "on Agents" do
    it_should_behave_like "CRUD allowed", Agent
  end
  context "on AgentRoles" do
    it_should_behave_like "CRUD allowed", AgentRole
  end
  context "on Stores" do
    it_should_behave_like "CRUD allowed", Store
  end
  context "on Customers" do
    it_should_behave_like "CRUD allowed", Customer
  end  
end