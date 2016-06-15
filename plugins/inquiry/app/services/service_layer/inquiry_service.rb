module ServiceLayer

  class InquiryService < Core::ServiceLayer::Service

    def available?(action_name_sym=nil)
      true
    end

    def get_inquiries(filter={})
      ::Inquiry::Inquiry.filter(filter).map { |i| ::Delegates::Inquiry.new(i) }
    end

    def get_inquiry(id)
      return Delegates::Inquiry.new(::Inquiry::Inquiry.find_by_id(id))
    end

    def set_inquiry_state(id, state, description)
      inquiry = ::Inquiry::Inquiry.find_by_id(id)
      inquiry.change_state(state, description, current_user)
      return Delegates::Inquiry.new(inquiry)
    end

    def create_inquiry(kind, description, requester_user, payload, processor_users, callbacks={}, domain_id=nil)
      # domain_id => user is domain scopr, project_domain_id => is in project scope, domain_id => override explizit
      domain_id = domain_id || requester_user.domain_id || requester_user.project_domain_id ||  requester_user.user_domain_id
      project_id = requester_user.project_id
      requester = Inquiry::Processor.from_users([requester_user]).first
      processors = Inquiry::Processor.from_users(processor_users).uniq
      inquiry = Inquiry::Inquiry.new(domain_id: domain_id, project_id: project_id, kind: kind, description: description, \
                                 requester: requester, payload: payload, processors: processors, callbacks: callbacks)
      inquiry.save!
      return Delegates::Inquiry.new(inquiry)
    end

    def change_inquiry(id, description=nil, payload=nil, callbacks=nil)
      inquiry = ::Inquiry::Inquiry.find_by_id(id)

      if ['new', 'open'].include inquiry.aasm_state
        inquiry.description = description if description
        inquiry.payload = payload if payload
        inquiry.callbacks = callbacks if callbacks
        inquiry.save!
      end
      return Delegates::Inquiry.new(inquiry)
    end

    def find_by_kind_user_states(kind, requester_id, states=[])
      get_inquiries({kind: kind, state: states, requester_id: requester_id})
    end

  end

end