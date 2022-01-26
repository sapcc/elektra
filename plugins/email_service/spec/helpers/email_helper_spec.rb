# require "spec_helper"

# RSpec.describe EmailService::EmailHelper, :type => :helper do

#   describe "#new_email" do

#     it "returns the Email instance" do
#       sampleEmail = EmailService::PlainEmailHelper::PlainEmail.new(assign(:attributes, {
#         source: "my@xyz.com",
#         to_addr: "asdf@ghi.com",
#         cc_addr: "mnop@rst.com",
#         bcc_addr: "glm@mpk.com",
#         subject: "This is a new Subject",
#         htmlbody: "<html><head><title>My title </title></head><body>This is my eMail</body></html>",
#         textbody: "This is my email"
#       }))
#       # puts sampleEmail.inspect
#       assign(:email, sampleEmail)
#       puts helper.new_email.inspect
#       # expect(helper.new_email.source).to eql("my@xyz.com")
#     end

#   end

# end