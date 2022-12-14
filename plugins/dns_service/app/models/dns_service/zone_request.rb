# frozen_string_literal: true

module DnsService
  class ZoneRequest < Core::ServiceLayer::Model
    validates :domain_type, presence: { message: "Please choose a domain type" }
    validates :domain_pool, presence: { message: "Please select a domain pool" }
    validates :name, presence: { message: "Please provide the domain name" }
    validates :email,
              presence: {
                message: "Please provide an email",
              },
              format: {
                with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i,
                message: "Please use a valid email address",
              }
    # disabled because it is not working correctly
    # validate :fqdn_check

    def subdomain?
      domain_type == "subdomain"
    end

    def zone_name
      # fully qualified domain name
      fq_name =
        (subdomain? && dns_domain.present? ? "#{name}.#{dns_domain}" : name)
      return "#{fq_name}." unless fq_name.last == "."
      fq_name
    end

    def fqdn_check
      # https://stackoverflow.com/questions/11809631/fully-qualified-domain-name-validation
      # Hostnames are composed of a series of labels concatenated with dots. Each label is 1 to 63 characters long, and may contain:
      # the ASCII letters a-z and A-Z, the digits 0-9, and the hyphen ('-'). Additionally: labels cannot start or end with hyphens (RFC 952)
      # labels can start with numbers (RFC 1123) trailing dot is not allowed max length of ascii hostname including dots is 253 characters
      if domain_type == "subdomain"
        if name.include?("_")
          errors.add("name", "Do not use underscore in subdomain names")
        end
        if name.include?(".")
          errors.add("name", "Dots are not allowed in subdomain names")
        end
        if name.start_with?("-")
          errors.add("name", 'Subdomain name cannot start with "-"')
        end
        if name.end_with?("-")
          errors.add("name", 'Subdomain name cannot end with "-"')
        end
        if name.length > 63
          errors.add("name", "Subdomain name cannot longer than 63 characters")
        end
      else
        unless name.match(
                 /(?=^.{4,253}$)(^((?!-)[a-zA-Z0-9-]{0,62}[a-zA-Z0-9]\.)+[a-zA-Z]{2,63}$)/i,
               )
          errors.add("name", "Please use a fully qualified domain name")
        end
      end
    end
  end
end
