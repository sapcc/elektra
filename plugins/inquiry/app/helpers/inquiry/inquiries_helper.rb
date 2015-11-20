module Inquiry
  module InquiriesHelper

    def get_allowed_custom_actions inquiry
      if inquiry.callbacks.nil? || inquiry.callbacks[inquiry.aasm_state].nil?
        return nil
      else
        inquiry.callbacks[inquiry.aasm_state]
      end
    end

  end
end
