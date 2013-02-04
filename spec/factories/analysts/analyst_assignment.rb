require 'factory_girl'

FactoryGirl.define do
  factory :analyst_assignment, class: AnalystAssignment do
    analyst       {|a| a.association(:analyst)}
    analyst_role  {|a| a.association(:analyst_role)}
  end
end