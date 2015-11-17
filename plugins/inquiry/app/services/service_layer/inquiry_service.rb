module ServiceLayer
  class InquiryService < DomainModelServiceLayer::Service
  
    def init(params)
    end

    def inquiries(filter={})
      Inquiry::Inquiry.all
    end

    def inquiry_create(kind, user, description)
      Inquiry::Inquiry.new(kind: kind, description: description, requester_id: user.id)
    end

  end
end