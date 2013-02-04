require 'spec_helper'
require 'cancan'
require 'cancan/matchers'

describe AgentAbility, :agent => true, :ability => true do
  let(:agent)   { FactoryGirl.create(:agent) }
  let(:ability) { AgentAbility.new(agent) }

  context "on Admins" do
    it_should_behave_like "CRUD restricted", Admin
  end
  context "on AdminRoles" do
    it_should_behave_like "CRUD restricted", AdminRole
  end
  context "on Agents" do
    it_should_behave_like "CRUD restricted", Agent
    specify { ability.should be_able_to(:read, agent) }
    specify { ability.should be_able_to(:update, agent) }
  end
  context "on AgentRoles" do
    it_should_behave_like "CRUD restricted", AgentRole
  end
  context "on Stores" do
    it_should_behave_like "CRUD allowed", Store
  end
  context "on Customers" do
    it_should_behave_like "CRUD allowed", Customer
  end  
end