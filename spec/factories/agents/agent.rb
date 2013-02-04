require 'factory_girl'

FactoryGirl.define do
  factory :agent, class: Agent do
    ignore do
      number_of_agent_roles  1
      agent_role_factory :agent_role
    end

    sequence(:username) {|n| "agent_#{n}" }
    password "fakepass"
    password_confirmation { password }
    email { "#{username}@credda.com" }
    email_confirmation { email }
    first_name "Agent"
    middle_name "Matrix"
    last_name "Smith"
    date_of_birth 31.years.ago
    terms_agreement "1"

    after(:build) do |agent, evaluator|
      evaluator.number_of_agent_roles.times do
        agent.agent_roles << FactoryGirl.create(evaluator.agent_role_factory, :number_of_agents => 0)
      end
    end
  end

  factory :invalid_agent, parent: :agent do
    password "validpass"
    password_confirmation "invalidpass"
  end
end