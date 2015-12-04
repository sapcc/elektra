module ServiceLayer
  class InquiryService < DomainModelServiceLayer::Service

    def find_by_id(id)
      Inquiry::Inquiry.find(id)
    end

    def inquiries(filter={})
      Inquiry::Inquiry.filter(filter)
    end

    def payload(id)
      i = Inquiry::Inquiry.find_by_id(id)
      if i
        return i.payload
      else
        return nil
      end
    end

    def inquiry_create(kind, description, requester_user, payload, processor_users, callbacks={})
      domain_id = requester_user.domain_id
      project_id = requester_user.project_id


      requester = Inquiry::Processor.from_users([requester_user]).first
      processors = Inquiry::Processor.from_users(processor_users)
      inq = Inquiry::Inquiry.new(domain_id: domain_id, project_id: project_id, kind: kind, description: description, \
                                 requester: requester, payload: payload, processors: processors, callbacks: callbacks)
      inq.save
      return inq
    end


  end
end