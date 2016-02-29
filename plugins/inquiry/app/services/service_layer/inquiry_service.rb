module ServiceLayer

  class InquiryService < Core::ServiceLayer::Service
    
    def available?(action_name_sym=nil)
      true
    end

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

    def inquiry_create(kind, description, requester_user, payload, processor_users, callbacks={}, register_domain_id=nil)
      # domain_id => user is domain scopr, project_domain_id => is in project scope, register_domain_id => no scope user is doing a registration
      domain_id = requester_user.domain_id || requester_user.project_domain_id || register_domain_id
      raise Inquiry::InquiryError.new "Missing Domain ID for Inquiry" unless domain_id

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

    private

    def set_state_for_inquiry(inquiry, state, description)
      sstate = state.to_sym
      inquiry.process_step_description = description
      if inquiry.valid?
        inquiry.reject!({user: current_user, description: description}) if sstate == :rejected
        inquiry.approve!({user: current_user, description: description}) if sstate == :approved
        inquiry.reopen!({user: current_user, description: description}) if sstate == :open
        inquiry.close!({user: current_user, description: description}) if sstate == :closed
      end
    end

  end

end