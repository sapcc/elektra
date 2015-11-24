module Inquiry
  module InquiriesHelper
    def remote_inquiries(options={})
      content_tag(:div, '',class: 'remote_inquiries', id: SecureRandom.hex, data: {
        url: plugin('inquiry').inquiries_path(),
        per_page: options[:per_page] || 3,
        filter: (options[:filter] || {}).to_json
      })
    end
  end
end
