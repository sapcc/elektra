class Delegates::Inquiry

  delegate :id, :description, :payload, :aasm_state, :requester, :errors, :errors?, to: :real_inquiry

  def initialize inquiry
    @real_inquiry = inquiry
  end

  private
  attr_reader :real_inquiry

end