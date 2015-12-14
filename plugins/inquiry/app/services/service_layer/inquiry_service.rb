module ServiceLayer

  class InquiryService < DomainModelServiceLayer::Service

    def find_by_id(id)
      Inquiry::Inquiry.find(id)
    end

    def inquiries(filter={})
      Inquiry::Inquiry.filter(filter)
    end

    def get_inquiry(id)
      return Delegates::Inquiry.new(find_by_id(id))
    end

    def payload(id)
      inquiry = Inquiry::Inquiry.find_by_id(id)
      if inquiry
        return inquiry.payload
      else
        return nil
      end
    end

    def status_close(id, description)
      inquiry = Inquiry::Inquiry.find_by_id(id)
      inquiry.process_step_description = description
      if inquiry.valid?
        return inquiry.close!({user: current_user, description: description})
      else
        return false
      end
    end

    def inquiry_create(kind, description, requester_user, payload, processor_users, callbacks={}, register_domain_id=nil)
      domain_id = requester_user.domain_id || register_domain_id
      project_id = requester_user.project_id

      requester = Inquiry::Processor.from_users([requester_user]).first
      processors = Inquiry::Processor.from_users(processor_users)
      inq = Inquiry::Inquiry.new(domain_id: domain_id, project_id: project_id, kind: kind, description: description, \
                                 requester: requester, payload: payload, processors: processors, callbacks: callbacks)
      inq.save!
      return inq
    end

    def inquiry_exists?(kind, requester_id, states=[])
      i = inquiries({kind: kind, state: states, requester_id: requester_id})
      if i.count == 1
        return i.first.id
      else
        return nil
      end
    end
  end

end