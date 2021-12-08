require 'spec_helper'

describe EmailService::ApplicationHelper do
  errors = [{ "name" => "Definition of Error" }]
  errors_html = "name: - Definition of Error"
  describe "render_error_messages" do 
    it "renders error messages" do
      expect(helper.render_error_messages(errors[0])).to match(errors_html) #equal(errors_html) 
    end
  end
end

