module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end
    
    private

    def find_verified_user
      # return if no domain provided
      return reject_unauthorized_connectio unless request.params[:domain_id]

      # access auth gem directly to get current user_id
      token_store = MonsoonOpenstackAuth::Authentication::TokenStore.new(
        request.session
      )
      
      current_token = token_store&.current_token(request.params[:domain_id])
      user_id = current_token && 
                current_token['user'] && 
                current_token['user']['id'] 

      user_id || reject_unauthorized_connection
    end
  end
end
