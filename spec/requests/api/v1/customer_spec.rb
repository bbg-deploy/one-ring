require 'spec_helper'

describe OneRing do
  let(:namespace) { "/api/v1/customer" }
  
  describe "GET /home" do
    context "as anonymous" do
      include_context "as anonymous"
      
      before(:each) do
        get "#{namespace}/home"
      end
      
      it "returns error" do
        response.status.should eq(401)
        JSON.parse(response.body).should eq("error" => "401 Unauthorized")
      end      
    end

    context "as customer" do
      include_context "as customer"
      
      before(:each) do
        get "#{namespace}/home"
      end
      
      it "returns error" do
        response.status.should eq(200)
        JSON.parse(response.body).should eq("error" => "401 Unauthorized")
      end      
    end
  end
end