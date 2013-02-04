module AttributeSharedExamples
  # Attribute Validation Methods
  #----------------------------------------------------------------------------
  shared_examples_for "attr_accessible" do |factory, attribute, valid_values, invalid_values|
    describe "#create", :create => true do
      context "with valid values" do
        valid_values.each do |value|
          it "builds successfully with #{attribute} => #{value}" do
            model = FactoryGirl.build(factory, attribute => value).should be_valid
          end
          it "saves successfully with #{attribute} => #{value}" do
            expect { FactoryGirl.create(factory, attribute => value) }.to_not raise_error
          end
        end        
      end
      context "with invalid values" do
        invalid_values.each do |value|
          it "fails build with #{attribute} => #{value}" do
            model = FactoryGirl.build(factory, attribute => value).should_not be_valid          
          end
          it "fails save with #{attribute} => #{value}" do
            expect { FactoryGirl.create(factory, attribute => value) }.to raise_error
          end
        end        
      end
    end      

    describe "#update", :update => true do
      let(:model) { FactoryGirl.create(factory) }
      context "with valid values" do
        valid_values.each do |value|
          it "saves successfully with #{attribute} => #{value}" do
            model.update_attributes(attribute => value).should be_true
            model.save.should be_true
          end        
        end
      end
      context "with invalid values" do
        invalid_values.each do |value|
          it "fails save with #{attribute} => #{value}" do
            model.update_attributes(attribute => value).should be_false
            model.save.should be_false
          end
        end        
      end
    end
  end

  shared_examples_for "immutable attribute" do |factory, attribute, valid_values, invalid_values|
    describe "#create", :create => true do
      context "with valid values" do
        valid_values.each do |value|
          it "builds successfully with #{attribute} => #{value}" do
            model = FactoryGirl.build(factory, attribute => value).should be_valid
          end
          it "saves successfully with #{attribute} => #{value}" do
            expect { FactoryGirl.create(factory, attribute => value) }.to_not raise_error
          end
        end
      end
      context "with invalid values" do
        invalid_values.each do |value|
          it "fails build with #{attribute} => #{value}" do
            model = FactoryGirl.build(factory, attribute => value).should_not be_valid          
          end
          it "fails save with #{attribute} => #{value}" do
            expect{ FactoryGirl.create(factory, attribute => value) }.to raise_error
          end
        end        
      end
    end

    describe "#update", :update => true do
      let(:model) { FactoryGirl.create(factory) }
      context "with valid values" do
        valid_values.each do |value|
          it "fails save with #{attribute} => #{value}" do
            expect{ model.update_attributes(attribute => value) }.to raise_error
          end        
        end
      end
      context "with invalid values" do
        invalid_values.each do |value|
          it "fails save with #{attribute} => #{value}" do
            expect{ model.update_attributes(attribute => value) }.to raise_error
          end
        end
      end
    end
  end

  shared_examples_for "attr_readonly" do |factory, attribute, valid_values, invalid_values|
    describe "#create", :create => true do
      context "with valid values" do
        valid_values.each do |value|
          it "builds successfully with #{attribute} => #{value}" do
            model = FactoryGirl.build(factory, attribute => value).should be_valid
          end
          it "saves successfully with #{attribute} => #{value}" do
            expect { FactoryGirl.create(factory, attribute => value) }.to_not raise_error
          end
        end        
      end
      context "with invalid values" do
        invalid_values.each do |value|
          it "fails build with #{attribute} => #{value}" do
            model = FactoryGirl.build(factory, attribute => value).should_not be_valid          
          end
          it "fails save with #{attribute} => #{value}" do
            expect{ FactoryGirl.create(factory, attribute => value) }.to raise_error
          end
        end        
      end
    end      

    describe "#update", :update => true do
      let(:model) { FactoryGirl.create(factory) }
      context "with valid values" do
        valid_values.each do |value|
          it "fails save with #{attribute} => #{value}" do
            expect{ model.update_attributes(attribute => value) }.to raise_error
          end        
        end
      end
      context "with invalid values" do
        invalid_values.each do |value|
          it "fails save with #{attribute} => #{value}" do
            expect{ model.update_attributes(attribute => value) }.to raise_error
          end
        end        
      end
    end
  end

  shared_examples_for "attr_protected" do |factory, attribute, valid_values, invalid_values|
    describe "#create", :create => true do
      context "with valid values" do
        valid_values.each do |value|
          it "saves successfully, but ignores #{attribute} => #{value}" do
            model = FactoryGirl.create(factory, attribute => value)
            model.send(attribute).should_not eq(value)
          end
        end
      end
      context "with invalid values" do
        invalid_values.each do |value|
          it "saves successfully, but ignores #{attribute} => #{value}" do
            model = FactoryGirl.create(factory, attribute => value)
            model.send(attribute).should_not eq(value)
          end
        end        
      end
    end      

    describe "#update", :update => true do
      let(:model) { FactoryGirl.create(factory) }
      context "with valid values" do
        valid_values.each do |value|
          it "fails save with #{attribute} => #{value}" do
            expect{ model.update_attributes(attribute => value) }.to raise_error
          end        
        end
      end
      context "with invalid values" do
        invalid_values.each do |value|
          it "fails save with #{attribute} => #{value}" do
            expect{ model.update_attributes(attribute => value) }.to raise_error
          end
        end        
      end
    end

    describe "#assignment", :update => true do
      let(:model) { FactoryGirl.create(factory) }
      context "with valid values" do
        valid_values.each do |value|
          it "can assign #{attribute} => #{value} before save" do
            model = FactoryGirl.create(factory)
            model.send("#{attribute}=", value)
            model.send(attribute).should eq(value)
          end
        end
      end
      context "with invalid values" do
        invalid_values.each do |value|
          it "does not save invalid #{attribute} => #{value} assignment" do
            model = FactoryGirl.create(factory)
            model.send("#{attribute}=", value)
            expect{ model.save! }.to raise_error
          end        
        end        
      end
    end
  end

  shared_examples_for "confirmable attr_accessible" do |factory, attribute, valid_values, invalid_values|
    describe "#create", :create => true do
      context "with valid values" do
        valid_values.each do |value|
          context "with match" do
            it "builds successfully with #{attribute} => #{value}" do
              confirmation_attribute = "#{attribute}_confirmation".to_sym
              model = FactoryGirl.build(factory, attribute => value, confirmation_attribute => value).should be_valid          
            end
            it "creates successfully with #{attribute} => #{value}" do
              confirmation_attribute = "#{attribute}_confirmation".to_sym
              expect { FactoryGirl.create(factory, attribute => value, confirmation_attribute => value) }.to_not raise_error
            end
          end
          context "with mismatch" do
            it "fails build with #{attribute} => #{value}" do
              confirmation_attribute = "#{attribute}_confirmation".to_sym
              mismatch = "mismatch"
              model = FactoryGirl.build(factory, attribute => value, confirmation_attribute => mismatch).should_not be_valid
            end
            it "fails create with #{attribute} => #{value}" do
              confirmation_attribute = "#{attribute}_confirmation".to_sym
              mismatch = "mismatch"
              expect { FactoryGirl.create(factory, attribute => value, confirmation_attribute => mismatch) }.to raise_error
            end
          end
        end        
      end

      context "with invalid values" do
        invalid_values.each do |value|
          context "with match" do
            it "fails build with #{attribute} => #{value}" do
                confirmation_attribute = "#{attribute}_confirmation".to_sym
                model = FactoryGirl.build(factory, attribute => value, confirmation_attribute => value).should_not be_valid
              end
            it "fails create with #{attribute} => #{value}" do
                confirmation_attribute = "#{attribute}_confirmation".to_sym
                expect { FactoryGirl.create(factory, attribute => value, confirmation_attribute => value) }.to raise_error
            end
          end
          context "with mismatch" do
            it "fails build with #{attribute} => #{value}" do
              confirmation_attribute = "#{attribute}_confirmation".to_sym
              mismatch = "mismatch"
              model = FactoryGirl.build(factory, attribute => value, confirmation_attribute => mismatch).should_not be_valid
            end
            it "fails create with #{attribute} => #{value}" do
              confirmation_attribute = "#{attribute}_confirmation".to_sym
              mismatch = "mismatch"
              expect { FactoryGirl.create(factory, attribute => value, confirmation_attribute => mismatch) }.to raise_error
            end
          end
        end 
      end
    end
    
    describe "#update", :update => true do
      let(:model) { FactoryGirl.create(factory) }
      context "with valid values" do
        valid_values.each do |value|
          context "with match" do
            it "updates successfully" do
              confirmation_attribute = "#{attribute}_confirmation".to_sym
              model.update_attributes({attribute => value, confirmation_attribute => value}).should be_true
              model.save.should be_true
            end
          end
          context "with mismatch" do
            it "fails update" do
              confirmation_attribute = "#{attribute}_confirmation".to_sym
              mismatch = "mismatch"
              model.update_attributes({attribute => value, confirmation_attribute => mismatch}).should be_false
              model.save.should be_false
            end
          end          
        end
      end
      context "with invalid values" do
        invalid_values.each do |value|          
          context "with match" do
            it "fails update with #{attribute} => #{value}" do
              confirmation_attribute = "#{attribute}_confirmation".to_sym
              model.update_attributes({attribute => value, confirmation_attribute => value}).should be_false
              model.save.should be_false
            end
          end
          context "with mismatch" do
            it "fails update with #{attribute} => #{value}" do
              confirmation_attribute = "#{attribute}_confirmation".to_sym
              mismatch = "mismatch"
              model.update_attributes({attribute => value, confirmation_attribute => mismatch}).should be_false
              model.save.should be_false
            end
          end          
        end
      end
    end
  end

  shared_examples_for "unique attr_accessible" do |factory, attribute, value|    
    describe "#create", :create => true do
      context "with #{value} available" do
        it "builds successfully with #{attribute} => #{value}" do
          model = FactoryGirl.build(factory, attribute => value).should be_valid          
        end
        it "creates successfully with #{attribute} => #{value}" do
          expect { FactoryGirl.create(factory, attribute => value) }.to_not raise_error
        end
      end
      context "with #{value} taken" do
        it "fails build with #{attribute} => #{value}" do
          original = FactoryGirl.create(factory, attribute => value)
          original.should be_valid
          model = FactoryGirl.build(factory, attribute => value).should_not be_valid          
        end
        it "fails create with #{attribute} => #{value}" do
          original = FactoryGirl.create(factory, attribute => value)
          original.should be_valid
          expect { FactoryGirl.create(factory, attribute => value) }.to raise_error
        end        
      end
    end
    
    describe "#update", :update => true do
      let(:model) { FactoryGirl.create(factory) }
      context "with #{value} available" do
        it "updates successfully with #{attribute} => #{value}" do
          model.update_attributes(attribute => value).should be_true
        end
      end
      context "with #{value} taken" do
        it "updates successfully with #{attribute} => #{value}" do
          original = FactoryGirl.create(factory, attribute => value)
          original.should be_valid
          model.update_attributes(attribute => value).should be_false
        end
      end
    end
  end
end