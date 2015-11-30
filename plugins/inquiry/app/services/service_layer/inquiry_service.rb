module ServiceLayer
  class InquiryService < DomainModelServiceLayer::Service

    def inquiry(id)
      Inquiry::Inquiry.find(id)
    end

    def inquiries(filter={})
      Inquiry::Inquiry.filter(filter)
    end

    def inquiry_create(kind, description, requester_user, payload, processor_users, callbacks={})
      domain_id = requester_user.domain_id
      project_id = requester_user.project_id

      processors = []
      processor_users.each do |user|
        processors << Inquiry::Processor.find_or_create_by(uid: user.id) do |p|
          p.email = user.email
          p.full_name = user.full_name
        end
      end
      inq = Inquiry::Inquiry.new(domain_id: domain_id, project_id: project_id, kind: kind, description: description, \
                                 requester_id: requester_user.id, requester_email: requester_user.email, requester_full_name: requester_user.full_name, \
                                 payload: payload, processors: processors, callbacks: callbacks)
      inq.save
      return inq
    end

  end
end