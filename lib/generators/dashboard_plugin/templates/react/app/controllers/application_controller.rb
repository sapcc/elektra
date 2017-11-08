# frozen_string_literal: true

module %{PLUGIN_NAME}
  class ApplicationController < DashboardController
    def index
      render inline: '', layout: true
    end

    def items
      render json: [
        { id: SecureRandom.uuid, name: 'Entry1', description: 'Test Entry 1'},
        { id: SecureRandom.uuid, name: 'Entry2', description: 'Test Entry 2'},
        { id: SecureRandom.uuid, name: 'Entry3', description: 'Test Entry 3'}
      ]
    end

    def create
      render json: {
        id: SecureRandom.uuid,
        name: params[:item][:name],
        description: params[:item][:description]
      }
    end

    def update
      render json: {
        id: params[:id],
        name: params[:item][:name],
        description: params[:item][:description]
      }
    end

    def destroy
      render head: :no_content
    end
  end
end
