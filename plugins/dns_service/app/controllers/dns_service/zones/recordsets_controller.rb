module DnsService
  module Zones
    class RecordsetsController < ApplicationController
      def show
        @recordset = services.dns_service.find_recordset(params[:zone_id],params[:id])
      end
    end
  end
end