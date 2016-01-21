require 'ruby-arc-client'
require 'ostruct'

module Automation

  class Facts < RubyArcClient::Facts

    def attributes
      attr = self.marshal_dump
      attr.each do |k, v|
        if v != true && v != false && v != 'true' && v != 'false'
          if v.blank?
            attr[k] = State::MISSING
          end
        end
      end
      attr
    end

  end

end