module AssociationSharedExamples
  # Association Validation Methods
  #----------------------------------------------------------------------------
  shared_examples_for "immutable polymorphic" do |factory, association|
    let(:model) { FactoryGirl.create(factory) }
    let(:new_model) { FactoryGirl.create(factory) }

    describe "association" do
      it "has association on create" do
        model.send(association).should_not be_nil
        model.send("#{association}_id").should_not be_nil
      end
  
      it "cannot be changed" do
        model.send("#{association}=", new_model.send(association))
        model.save
        model.reload
        model.send(association).should_not eq(new_model.send(association))
      end
    end

    describe "association_id" do
      it "has association on create" do
        model.send("#{association}_id").should_not be_nil
      end
  
      it "cannot be changed" do
        model.send("#{association}_id=", new_model.send("#{association}_id"))
        model.save
        model.reload
        model.send("#{association}_id").should_not eq(new_model.send("#{association}_id"))
      end
    end
  end
  
  shared_examples_for "required belongs_to" do |factory, association|
    specify { expect { FactoryGirl.create(factory, association => nil) }.to raise_error }
  end
  
  shared_examples_for "immutable belongs_to" do |factory, association|
    let(:model_1) { FactoryGirl.create(factory) }
    let(:model_2) { FactoryGirl.create(factory) }

    it "cannot be changed" do
      owner_1 = model_1.send(association)
      owner_2 = model_2.send(association)
      owner_1.should_not eq(owner_2)
      model_2.send("#{association}=", owner_1)
      model_2.send(association).should eq(owner_1)
      model_2.save
      model_2.reload
      model_2.send(association).should_not eq(owner_1)
    end
  end

  shared_examples_for "deletable belongs_to" do |factory, association|
    let(:model_1) { FactoryGirl.create(factory) }

    it "can be destroyed directly" do
      model_1.destroy
      expect{ model_1.reload }.to raise_error      
    end
  end

  shared_examples_for "dependent destroy" do |factory, attribute|
    it "destroys dependent #{attribute}" do
      model = FactoryGirl.create(factory)
      dependent = model.send(attribute)

      if dependent.kind_of?(Array)
        dependent.should_not be_empty
        model.destroy
        dependent.should be_empty
      else
        dependent.should_not be_nil
        model.destroy
        expect{ model.send(attribute).reload }.to raise_error
      end
    end
  end

  #TODO: Phase out all below here:
  #------------------------------------------------------
  shared_examples_for "required association" do
    specify { expect { FactoryGirl.create(factory, nested_attribute_modifier => 0) }.to raise_error }
    specify { expect { FactoryGirl.create(factory, nested_attribute_modifier => 1) }.to_not raise_error }
  end
  
  shared_examples_for "restricted has_many" do |limit|
    context "on create" do
      specify { expect { FactoryGirl.create(factory, nested_attribute_modifier => (limit)) }.to_not raise_error }
      specify { expect { FactoryGirl.create(factory, nested_attribute_modifier => (limit + 1)) }.to raise_error }
    end
    context "on update" do
      context "with < #{limit} records" do
        let(:model) { FactoryGirl.create(factory, nested_attribute_modifier => (limit - 1)) }
        it "successfully adds address" do
          unless (limit == 1) && (required_has_many)
            model.send(nested_model).create( nested_model_attributes )
            model.send(nested_model).size.should eq(limit)
          end
        end
      end
      context "with LIMIT records" do
        let(:model) { FactoryGirl.create(factory, nested_attribute_modifier => (limit)) }
        it "fails create! new record" do
          expect {
            model.send(nested_model).create!( nested_model_attributes )            
          }.to raise_error
        end
        it "does not persist new records" do
          model.send(nested_model).create( nested_model_attributes )
          model.send(nested_model).size.should eq(limit + 1)
          model.reload
          model.send(nested_model).size.should eq(limit)
        end
      end
    end  
  end
end