module Inquiry
  module InquiriesHelper
    def get_allowed_custom_actions inquiry
      if inquiry.callbacks.nil? || inquiry.callbacks[inquiry.aasm_state].nil?
        return nil
      else
        inquiry.callbacks[inquiry.aasm_state]
      end
    end

    # This method loads remote inquiries via ajax into a new created div.
    def remote_inquiries(options={})
      content_tag(:div, '',class: 'inquiry-widget', id: SecureRandom.hex, data: {
        widget: 'inquiry',
        url: plugin('inquiry').inquiries_path(),
        per_page: options[:per_page] || 3,
        filter: (options[:filter] || {}).to_json
      })
    end
  end
end
