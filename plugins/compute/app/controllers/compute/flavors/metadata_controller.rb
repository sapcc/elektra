# frozen_string_literal: true

module Compute
  module Flavors
    class MetadataController < ::ApplicationController
      def index
        @flavor = services.compute.find_flavor(params[:flavor_id])
        @metadata = services.compute.find_flavor_metadata!(params[:flavor_id])
      end

      # TODO: after creating the metadate the list in the modal window is wrong
      def create
        @metadata = services.compute.new_flavor_metadata(params[:flavor_id])
        @metadata.add(params[:spec])
      end

      def destroy
        @metadata = services.compute.new_flavor_metadata(params[:flavor_id])
        @metadata.remove(params[:key])
      end
    end
  end
end
