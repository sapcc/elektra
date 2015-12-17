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

    def set_state(id, state, description)
      inquiry = Inquiry::Inquiry.find_by_id(id)
      set_state_for_inquiry(inquiry, state, description)
      return Delegates::Inquiry.new(inquiry)
    end

    def set_state_for_inquiry(inquiry, state, description)
      inquiry.process_step_description = description
      if inquiry.valid?
        inquiry.reject!({user: current_user, description: description}) if state == :rejected
        inquiry.approve!({user: current_user, description: description}) if state == :approved
        inquiry.reopen!({user: current_user, description: description}) if state == :open
        inquiry.close!({user: current_user, description: description}) if state == :closed
      end
    end

    def inquiry_create(kind, description, requester_user, payload, processor_users, callbacks={}, register_domain_id=nil)
      domain_id = requester_user.domain_id || register_domain_id
      project_id = requester_user.project_id

      requester = Inquiry::Processor.from_users([requester_user]).first
      processors = Inquiry::Processor.from_users(processor_users)
      inquiry = Inquiry::Inquiry.new(domain_id: domain_id, project_id: project_id, kind: kind, description: description, \
                                 requester: requester, payload: payload, processors: processors, callbacks: callbacks)
      inquiry.save!
      return Delegates::Inquiry.new(inquiry)
    end

    def find_by_kind_user_states(kind, requester_id, states=[])
      i = inquiries({kind: kind, state: states, requester_id: requester_id})
      if i.count > 0
        return Delegates::Inquiry.new(i.first)
      else
        return nil
      end
    end
  end

end