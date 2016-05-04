module Compute
  class Keypair < Core::ServiceLayer::Model

    validate :public_key_valid?
    validates :name, :public_key, presence: true

    protected

    def id
      return nil #name
    end

    def public_key_valid?
      begin
        Net::SSH::KeyFactory.load_data_public_key(public_key)
      rescue => e
        puts e
        errors.add :public_key, "#{name} is not a valid ssh public key"
      end
    end

  end
end