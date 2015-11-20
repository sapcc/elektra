module ServiceLayer
  class InquiryService < DomainModelServiceLayer::Service

    def inquiry(id)
      Inquiry::Inquiry.find(id)
    end

    def inquiries(filter={})
      Inquiry::Inquiry.filter(filter)
    end

    def inquiry_create(kind, description, request_user, payload, processor_uids, callbacks={})
      domain_id = request_user.domain_id
      project_id = request_user.project_id

      processors = []
      processor_uids.each do |puid|
        processors << Inquiry::Processor.find_or_create_by(uid: puid)
      end
      inq = Inquiry::Inquiry.new(domain_id: domain_id, project_id: project_id, kind: kind, description: description, \
                                 requester_id: request_user.id, payload: payload, processors: processors, callbacks: callbacks)
      inq.save
      return inq
    end

  end
end