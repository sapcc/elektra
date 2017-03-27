module DnsService
  class ZoneRequest < Core::ServiceLayer::Model
    validates :name, presence: {message: 'Please provide the domain name'}
    validates :email, presence: {message: 'Please provide an email'}
  end
end
