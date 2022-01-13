# frozen_string_literal: true

module ServiceLayer
  module NetworkingServices
    # Implements Openstack Network
    module Interconnection

      def interconnections(filter = {})
        return 200, elektron_networking.get('interconnection/interconnections', filter).body
      rescue Elektron::Errors::ApiResponse => e
        return e.code, e.messages.join(', ')
      end

      def create_interconnection(params)
        return 201, elektron_networking.post("interconnection/interconnections") do 
          {
            "interconnection": params
          }
        end
      rescue Elektron::Errors::ApiResponse => e
        return e.code, e.messages.join(', ')
      end

      def delete_interconnection(id)
        return 201, elektron_networking.delete("interconnection/interconnections/#{id}")
      rescue Elektron::Errors::ApiResponse => e
        return e.code, e.messages.join(', ')
      end
    end
  end
end
