# frozen_string_literal: true

module DnsService
  class ZoneRequest < Core::ServiceLayer::Model
    validates :domain_type, presence: { message: 'Please choose a domain type' }
    validates :domain_pool, presence: { message: 'Please select a domain pool' }
    validates :name, presence: { message: 'Please provide the domain name' }
    validates :email, presence: { message: 'Please provide an email' }

    def subdomain?
      domain_type == 'subdomain'
    end

    def zone_name
      # fully qualified domain name
      fq_name = if subdomain? && dns_domain.present?
                  "#{name}.#{dns_domain}"
                else
                  name
                end
      return "#{fq_name}." unless fq_name.last == '.'
      fq_name
    end
  end
end
