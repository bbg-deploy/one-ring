require 'spec_helper'
require 'cancan'
require 'cancan/matchers'

describe AnalystAbility, :analyst => true, :ability => true do
  let(:analyst) { FactoryGirl.create(:analyst) }
  let(:ability) { AnalystAbility.new(analyst) }

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
    it_should_behave_like "CRUD restricted", AdminRole
  end
  context "on Analysts" do
    it_should_behave_like "CRUD restricted", Analyst
    specify { ability.should be_able_to(:read, analyst) }
    specify { ability.should be_able_to(:update, analyst) }
  end
  context "on AnalystRoles" do
    it_should_behave_like "CRUD restricted", AnalystRole
  end
  context "on Stores" do
    it_should_behave_like "CRUD restricted", Store
  end
  context "on Customers" do
    it_should_behave_like "CRUD restricted", Customer
  end  
end