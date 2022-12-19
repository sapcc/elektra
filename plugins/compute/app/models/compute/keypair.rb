# frozen_string_literal: true

module Compute
  # Represents the Key Value pair
  class Keypair < Core::ServiceLayer::Model
    validate :public_key_valid?
    validates :name, :public_key, presence: true

    protected

    def id
      nil # name
    end

    def public_key_valid?
      Net::SSH::KeyFactory.load_data_public_key(public_key)
    rescue StandardError
      errors.add :public_key, "#{name} is not a valid ssh public key"
    end

    def attributes_for_create
      {
        "name" => read("name"),
        "public_key" => read("public_key"),
      }.delete_if { |_k, v| v.nil? }
    end
  end
end
