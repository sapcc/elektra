module ServiceLayerNg
  # This module implements Openstack Domain API
  module Keypair

    def keypairs()
      debug "[compute-service][Keypair] -> keypairs -> GET /list_keypairs"
      # keypair structure different to others, so manual effort needed
      unless @user_keypairs
        @user_keypairs = []
        keypairs = api.compute.list_keypairs.map_to(Compute::Keypair)
        keypairs.each do |k|
          kp = Compute::Keypair.new(self)
          kp.attributes = k.keypair if k.keypair
          @user_keypairs << kp if kp
        end
      end
      return @user_keypairs
    end

  end
end