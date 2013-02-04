require 'factory_girl'

FactoryGirl.define do
  factory :agent_assignment, class: AgentAssignment do
    agent       {|a| a.association(:agent, number_of_agent_roles: 0)}
    agent_role  {|a| a.association(:agent_role)}
  end
end