module AbilitySharedExamples
  # Abilities
  #----------------------------------------------------------------------------
  shared_examples_for "CRUD allowed" do |objectClass|
    specify { ability.should be_able_to(:create, objectClass) }
    specify { ability.should be_able_to(:read, objectClass.new) }
    specify { ability.should be_able_to(:update, objectClass.new) }
    specify { ability.should be_able_to(:delete, objectClass.new) }
  end

  shared_examples_for "CRUD restricted" do |objectClass|
    specify { ability.should_not be_able_to(:create, objectClass) }
    specify { ability.should_not be_able_to(:read, objectClass.new) }
    specify { ability.should_not be_able_to(:update, objectClass.new) }
    specify { ability.should_not be_able_to(:delete, objectClass.new) }
  end
end