# # frozen_string_literal: true
#
# module ServiceLayerNg
#   # This module implements Openstack Compute Image API
#   module ComputeServices
#     # server snapshots
#     module Image
#       def image_map
#         @image_map ||= class_map_proc(Compute::Image)
#       end
#
#       def find_image!(image_id, use_cache = false)
#         byebug
#         image_data = if use_cache
#                        Rails.cache.fetch("server_image_#{image_id}",
#                                          expires_in: 24.hours) do
#                          api.compute.show_image_details(image_id).data
#                        end
#                      else
#                        data = api.compute.show_image_details(image_id).data
#                        Rails.cache.write("server_image_#{image_id}", data,
#                                          expires_in: 24.hours)
#                        data
#                      end
#
#         return nil if image_data.nil?
#         map_to(Compute::Image, image_data)
#       end
#
#       def find_image(image_id, use_cache = false)
#         find_image!(image_id, use_cache)
#       rescue
#         nil
#       end
#
#       # this is called from server model
#       def create_image(server_id, name, metadata = {})
#         api.compute.create_image_createimage_action(
#           server_id, 'createImage' => { 'name' => name, 'metadata' => metadata }
#         )
#       end
#     end
#   end
# end
