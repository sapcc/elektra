class Delegates::Inquiry
  delegate :id,
           :description,
           :payload,
           :domain_id,
           :project_id,
           :aasm_state,
           :requester,
           :errors,
           :errors?,
           :valid?,
           :nil?,
           to: :real_inquiry

  def initialize(inquiry)
    @real_inquiry = inquiry
  end

  def present?
    !real_inquiry.nil?
  end

  private

  attr_reader :real_inquiry
end
