module Automation
  class Facts < ArcClient::Facts
    def attributes
      attr = self.marshal_dump
      attr.each do |k, v|
        if v != true && v != false && v != "true" && v != "false"
          attr[k] = State::MISSING if v.blank?
        end
      end
      attr
    end

    def online_to_string
      case self.online
      when State::Node::ONLINE
        "Online"
      when State::Node::OFFLINE
        "Offline"
      else
        State::MISSING
      end
    end
  end
end
