module SharedFilesystemStorage
  class SharesController < ApplicationController
    def index
      @shares = services.shared_filesystem_storage.shares_detail
      @shares.each do |share| 
        share.permissions = {
          delete: current_user.is_allowed?("shared_filesystem_storage:share_delete"), 
          update: current_user.is_allowed?("shared_filesystem_storage:share_update")
        }
      end
      render json: @shares
      
      
      puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><"
      services.shared_filesystem_storage.share_export_locations(@shares.first.id).each do |el|
        puts el.pretty_attributes
      end
      raise
    end
    
    # def show
    #   share = services.shared_filesystem_storage.find_share(params[:id])
    #
    #   share.permissions = {
    #     delete: current_user.is_allowed?("shared_filesystem_storage:share_delete"),
    #     update: current_user.is_allowed?("shared_filesystem_storage:share_update")
    #   }
    #   render json: share
    # end
    #
    def availability_zones
      #TODO: load availability zones from manila (not implemented yet in FOG!)
      # render json: services.shared_filesystem_storage.availability_zones
      render json: []
    end
    
    def update
      share = services.shared_filesystem_storage.new_share(share_params)
      share.id = params[:id]

      if share.save
        share.permissions = {
          delete: current_user.is_allowed?("shared_filesystem_storage:share_delete"), 
          update: current_user.is_allowed?("shared_filesystem_storage:share_update")
        }
        render json: share
      else
        render json: share.errors, status: :unprocessable_entity
      end  
    end

    def create
      share = services.shared_filesystem_storage.new_share(share_params)
      share.share_type ||= "default"
      
      if share.save
        share.permissions = {
          delete: current_user.is_allowed?("shared_filesystem_storage:share_delete"), 
          update: current_user.is_allowed?("shared_filesystem_storage:share_update")
        }
        render json: share
      else
        render json: share.errors, status: :unprocessable_entity
      end
    end
    
    def destroy
      @share = services.shared_filesystem_storage.new_share
      @share.id=params[:id]
      
      if @share.destroy
        head :no_content
      else
        render json: @share.errors, status: :unprocessable_entity
      end
    end
    
    protected
    
    def share_params
      params.require(:share).permit(:share_proto,:size,:name,:description,:display_name,:display_description,:share_type,:volume_type,
      :snapshot_id,:is_public,:metadata,:share_network_id,:consistency_group_id,:availability_zone)
    end
  end
end