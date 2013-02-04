require 'spec_helper'
require 'cancan'
require 'cancan/matchers'

describe AnonymousAbility, :anonymous => true, :ability => true do
  let(:ability) { AnonymousAbility.new }

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
  end  
end