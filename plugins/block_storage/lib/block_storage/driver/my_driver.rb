module BlockStorage
  module Driver
    # Compute calls
    class MyDriver < Interface
    
      def initialize(params)
        super(params)
        @connection = nil #::Fog::Network::OpenStack.new(auth_params)
      end
      
      def test(filter={})
        puts "test"
      end  
    end
  end
end