require 'factory_girl'

FactoryGirl.define do
  factory :admin_assignment, class: AdminAssignment do
    admin       {|a| a.association(:admin)}
    admin_role  {|a| a.association(:admin_role)}
  end
end