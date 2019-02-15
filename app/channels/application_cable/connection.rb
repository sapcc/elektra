module ApplicationCable
  class Connection < ActionCable::Connection::Base
    include CurrentUserWrapper
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end
    
    private

    def find_verified_user
      return rejectnunauthorized_connection unless request.params[:domain_id]

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
