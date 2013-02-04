require 'factory_girl'

FactoryGirl.define do
  factory :agent_role, class: AgentRole do
    ignore do
      number_of_agents  3
      agent_factory :agent
    end

    sequence(:name) {|n| "agent_role_#{n.to_words.parameterize.underscore}" }
    description "Agent role description"
    permanent true

    after(:build) do |agent_role, evaluator|
      evaluator.number_of_agents.times do
        agent_role.agents << FactoryGirl.create(evaluator.agent_factory)
      end
    end
  end
end