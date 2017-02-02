module Loadbalancing
  class L7policy < Core::ServiceLayer::Model
    include ActiveModel::Conversion

    ACTIONS= ['REDIRECT_TO_URL', 'REDIRECT_TO_POOL', 'REJECT']

    validates :action, presence: true
    validates :name, presence: true
    validates :redirect_pool_id, presence: { message: "Please choose a Pool for redirection" }, if: "action == 'REDIRECT_TO_POOL'"
    validates :redirect_url, presence: { message: "Please choose a Url for redirection" }, if: "action == 'REDIRECT_TO_URL'"

    attr_accessor :in_transition

    def in_transition?
      false
    end

  end
end
