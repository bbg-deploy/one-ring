require 'spec_helper'

describe Admin::ApplicationController do
  context "as an anonymous user" do
    include_context "as anonymous"
    specify { subject.current_admin.should be_nil }
  end

  context "as an signed-in administrator" do
    include_context "as admin"
    specify { subject.current_admin.should_not be_nil }

    it "has a current admin" do
      subject.current_admin.should_not be_nil
    end
  end
end