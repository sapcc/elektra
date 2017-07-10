module Loadbalancing
  class L7policy < Core::ServiceLayer::Model
    include ActiveModel::Conversion

    PREDEFINED_POLICIES = [ { protocols: ['TCP'], ids: ['proxy_protocol_2edF_v1_0']}
                            #{ protocols: ['HTTP', 'HTTPS', 'TERMINATED_HTTPS'], ids: ['x_forwarded_for_2edF_v1_0']}
                          ]
    ACTIONS= ['REDIRECT_TO_URL', 'REDIRECT_TO_POOL', 'REJECT']

    validates :action, presence: true
    validates :name, presence: true
    validates :redirect_pool_id, presence: { message: "Please choose a Pool for redirection" }, if: "action == 'REDIRECT_TO_POOL'"
    validates :redirect_url, presence: { message: "Please choose a Url for redirection" }, if: "action == 'REDIRECT_TO_URL'"

    attr_accessor :in_transition

    def in_transition?
      false
    end

    def predefined?
      PREDEFINED_POLICIES.each do |p|
        if p[:ids].include? name
          return true
        end
      end
      return false
    end

    def self.predefined protocol
      policies = []
      PREDEFINED_POLICIES.each do |p|
        if p[:protocols].include? protocol
          policies << p
        end
      end
      return policies
    end

  end
end
