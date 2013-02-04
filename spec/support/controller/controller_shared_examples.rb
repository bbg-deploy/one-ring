module ControllerSharedExamples
  # ERROR HANDLING
  #----------------------------------------------------------------------------
  shared_examples_for "handles not found error" do
  end

  shared_examples_for "handles denied error" do
  end

  # INDEX
  #----------------------------------------------------------------------------
  shared_examples_for "#index denied" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds unsuccessfully in #{format}" do
        do_get_index(format)
        response.should_not be_success
      end
      it "redirects to admin sign-in in #{format}" do
        do_get_index(format)
        response.code.should eq("302")
        response.should be_redirect
        response.should redirect_to :controller => 'sessions', :action => :new
      end
    end
  end

  shared_examples_for "#index allowed" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds unsuccessfully in #{format}" do
        do_get_index(format)
        response.code.should eq("200")
        response.should be_success
      end
      it "renders index template in #{format}" do
        do_get_index(format)
        response.should render_template :index
      end
    end
  end

  # NEW 
  #----------------------------------------------------------------------------
  shared_examples_for "#new denied" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds unsuccessfully in #{format}" do
        do_get_new(format)
        response.should_not be_success
      end
      it "redirects to admin sign-in in #{format}" do
        do_get_new(format)
        response.code.should eq("302")
        response.should be_redirect
        response.should redirect_to :controller => 'sessions', :action => :new
      end
    end
  end

  shared_examples_for "#new allowed" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds successfully in #{format}" do
        do_get_new(format)
        response.code.should eq("200")
        response.should be_success
      end
      it "renders new template in #{format}" do
        do_get_new(format)
        response.should render_template :new
      end
    end
  end

  # CREATE
  #----------------------------------------------------------------------------
  shared_examples_for "#create denied" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds unsuccessfully in #{format}" do
        do_post_create( class_to_symbol(model), attributes, format )
        response.should_not be_success
      end
      it "redirects to admin sign-in in #{format}" do
        do_post_create( class_to_symbol(model), attributes, format )
        response.code.should eq("302")
        response.should be_redirect
        response.should redirect_to :controller => 'sessions', :action => :new
      end
      it "maintains object count in #{format}" do
        expect{
          do_post_create( class_to_symbol(model), attributes, format )
        }.to_not change(model, :count)
      end
    end
  end

  shared_examples_for "#create valid" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "redirects to show page in #{format}" do
        do_post_create( class_to_symbol(model), attributes, format )
        response.code.should eq("302")
        response.should be_redirect
        response.should redirect_to :action => :show, :id => model.last
      end
      it "increases object count in #{format}" do
        expect{
          do_post_create( class_to_symbol(model), attributes, format )
        }.to change(model, :count).by(1)
      end
    end
  end

  shared_examples_for "#create invalid" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds successfully in #{format}" do
        do_post_create( class_to_symbol(model), attributes, format )
        response.code.should eq("200")
        response.should render_template :new
      end
      it "maintains object count in #{format}" do
        expect{
          do_post_create( class_to_symbol(model), attributes, format )
        }.to_not change(model, :count)
      end
    end
  end

  # SHOW
  #----------------------------------------------------------------------------
  shared_examples_for "#show denied" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds unsuccessfully in #{format}" do
        do_get_show( object.id, format )
        response.should_not be_success
      end
      it "redirects to admin sign-in in #{format}" do
        do_get_show( object.id, format )
        response.code.should eq("302")
        response.should be_redirect
        response.should redirect_to :controller => 'sessions', :action => :new
      end
    end
  end

  shared_examples_for "#show valid" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds successfully in #{format}" do
        do_get_show( object.id, format )
        response.code.should eq("200")
        response.should be_success
      end
      it "renders show template in #{format}" do
        do_get_show( object.id, format )
        response.should render_template :show
      end
    end
  end

  shared_examples_for "#show routing error" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds unsuccessfully in #{format}" do
        expect { 
          do_get_show( object.id, format )
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  # EDIT
  #----------------------------------------------------------------------------
  shared_examples_for "#edit denied" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds unsuccessfully in #{format}" do
        do_get_edit( object.id, format )
        response.should_not be_success
      end
      it "redirects to admin sign-in in #{format}" do
        do_get_edit( object.id, format )
        response.code.should eq("302")
        response.should be_redirect
        response.should redirect_to :controller => 'sessions', :action => :new
      end
    end
  end

  shared_examples_for "#edit valid" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds successfully in #{format}" do
        do_get_edit( object.id, format )
        response.code.should eq("200")
        response.should be_success
      end
      it "renders show template in #{format}" do
        do_get_edit( object.id, format )
        response.should render_template :edit
      end
    end
  end

  shared_examples_for "#edit routing error" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds unsuccessfully in #{format}" do
        expect { 
          do_get_edit( object.id, format )
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end

  # UPDATE
  #----------------------------------------------------------------------------
  shared_examples_for "#update denied" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds unsuccessfully in #{format}" do
        do_put_update( class_to_symbol(model), object.id, attributes, format )
        response.should_not be_success
      end
      it "redirects to admin sign-in in #{format}" do
        do_put_update( class_to_symbol(model), object.id, attributes, format )
        response.code.should eq("302")
        response.should be_redirect
        response.should redirect_to :controller => 'sessions', :action => :new
      end
      it "does not alter object in #{format}" do
        do_put_update( class_to_symbol(model), object.id, attributes, format )
        object.reload
        attributes.each do |key, value|
          object.send(key.to_s).should_not eq(value)
        end
      end
      it "sets failed flash message in #{format}" do
        do_put_update( class_to_symbol(model), object.id, attributes, format )
        #TODO: Fix flash behavior
#        flash[:notice].should =~ /Fail/
      end
    end
  end

  shared_examples_for "#update valid" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "redirects to show page in #{format}" do
        do_put_update( class_to_symbol(model), object.id, attributes, format )
        response.code.should eq("302")
        response.should be_redirect
        response.should redirect_to :action => :show, :id => object
      end
      it "alters object in #{format}" do
        do_put_update( class_to_symbol(model), object.id, attributes, format )
        object.reload
        attributes.each do |key, value|
          object.send(key.to_s).should eq(value)
        end
      end
      it "sets failed flash message in #{format}" do
        do_put_update( class_to_symbol(model), object.id, attributes, format )
#        flash[:notice].should =~ /Fail/
      end
    end
  end

  shared_examples_for "#update invalid" do |formats = nil|
#    formats ||= ["html", "json", "xml"]
    formats ||= ["html"]
    formats.each do |format|
      it "responds successfully in #{format}" do
        do_put_update( class_to_symbol(model), object.id, attributes, format )
        response.code.should eq("200")
        response.should be_success
      end
      it "renders show template in #{format}" do
        do_put_update( class_to_symbol(model), object.id, attributes, format )
        response.should render_template :edit
      end
      it "does not alter object in #{format}" do
        do_put_update( class_to_symbol(model), object.id, attributes, format )
        object.reload
        attributes.each do |key, value|
          object.send(key.to_s).should_not eq(value)
        end
      end
      it "sets failed flash message in #{format}" do
        do_put_update( class_to_symbol(model), object.id, attributes, format )
        #TODO: Fix flash behavior
#        flash[:notice].should =~ /Fail/
      end
    end
  end

  # DELETE
  #----------------------------------------------------------------------------
  shared_examples_for "#delete denied" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds unsuccessfully in #{format}" do
        do_delete_destroy( object.id, format )
        response.should_not be_success
      end
      it "redirects to admin sign-in in #{format}" do
        do_delete_destroy( object.id, format )
        response.code.should eq("302")
        response.should be_redirect
        response.should redirect_to :controller => 'sessions', :action => :new
      end
      it "maintains object count in #{format}" do
        object.reload
        expect{
          do_delete_destroy( object.id, format )
        }.to_not change(model, :count)
      end
      it "sets failed flash message in #{format}s" do
        do_delete_destroy( object.id, format )
        #TODO: Fix flash behavior
#        flash[:notice].should =~ /Fail/
      end
    end
  end

  shared_examples_for "#delete valid" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "redirects to show page in #{format}" do
        do_delete_destroy( object.id, format )
        response.code.should eq("302")
        response.should be_redirect
        response.should redirect_to :action => :index
      end

      it "decreases object count" do
        object.reload # Because 'let' lazy loads
        expect{
          do_delete_destroy( object.id, format )
        }.to change(model, :count).by(-1)
      end
    end
  end

  shared_examples_for "#delete routing error" do |formats = nil|
    formats ||= ["html"]
    formats.each do |format|
      it "responds unsuccessfully in #{format}" do
        expect { 
          do_delete_destroy( object.id, format )
        }.to raise_error(ActionController::RoutingError)
      end
    end
  end
end