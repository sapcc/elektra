module Loadbalancing
  class L7rule < Core::ServiceLayer::Model

    TYPES          = ['HOST_NAME', 'PATH', 'FILE_TYPE', 'HEADER', 'COOKIE']
    COMPARE_TYPES  = ['EQUAL_TO', 'STARTS_WITH', 'ENDS_WITH', 'CONTAINS', 'REGEX']

    validates :key, presence: { message: "Please set a key name for Cookie and Header types" }, if: "type == 'HEADER' || type == 'COOKIE'"
    validates :key, format: { with: /\A[a-zA-Z!#$%&'*+-.^_`|~]+\z/, message: "Invalid characters in value. See RFCs 2616, 2965, 6265, 7230." }, if: "type == 'HEADER' || type == 'COOKIE'"
    validates :value, presence: true, format: { with: /\A[a-zA-Z\d!#$%&'()*+-\.\/:<=>?@\[\]^_`{|}~]+\z/, message: "Invalid characters in value. See RFCs 2616, 2965, 6265." }

    attr_accessor :in_transition

    def rule_formula
      s = self.type + ' '
      s += 'NOT ' if self.invert
      s += self.compare_type + ' '
      s = s.humanize
      s += ("KEY[#{self.key}]=") if self.key
      s += self.value
      return s
    end

    def in_transition?
      false
    end

  end
end
