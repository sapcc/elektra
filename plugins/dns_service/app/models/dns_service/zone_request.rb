module DnsService
  class ZoneRequest < Core::ServiceLayer::Model
    validates :domain_type, presence: {message: 'Please choose a domain type'}
    validates :domain_pool, presence: {message: 'Please select a domain pool'}
    validates :name, presence: {message: 'Please provide the domain name'}
    validates :email, presence: {message: 'Please provide an email'}
  end
end
