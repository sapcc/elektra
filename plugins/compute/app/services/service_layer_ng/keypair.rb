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

    def new_keypair(params = {})
      # this is used for inital create keypair dialog
      debug "[compute-service][Keypair] -> new_keypair"
      Compute::Keypair.new(self,params)
    end

    def create_keypair(params = {})

      debug "[compute-service][Keypair] -> create_keypair -> POST /os-keypairs"
      debug "[compute-service][Keypair] -> create_keypair -> Parameter: #{params}"

      data = {
        'keypair' => {
          'name' => params['name']
        }
      }

      data['keypair']['public_key'] = params['public_key'] unless params['public_key'].nil?

      api.compute.create_or_import_keypair(data).data

    end

    def find_keypair(keypair_name=nil)
      debug "[compute-service][Keypair] -> find_keypair -> GET /os-keypairs/#{keypair_name}"
      return nil if keypair_name.blank?
      api.compute.show_keypair_details(keypair_name).map_to(Compute::Keypair)
    end

    def delete_keypair(keypair_name=nil)
      debug "[compute-service] -> delete_keypair -> DELETE /os-keypairs/#{keypair_name} "
      return nil if keypair_name.blank?
      api.compute.delete_keypair(keypair_name)
    end

  end
end