# frozen_string_literal: true

# we dont use Keystone credential store anymore
# can be deleted later

# module ServiceLayer
#   module IdentityServices
#     # This module implements Openstack Credential API
#     module OsCredential
#       def os_credential_map
#         @os_credential_map ||= class_map_proc(Identity::OsCredential)
#       end

#       def new_credential(attributes = {})
#         os_credential_map.call(attributes)
#       end

#       def find_credential(id = nil)
#         return nil if id.blank?
#         elektron_identity.get("credentials/#{id}").map_to(
#           'body.credential', &os_credential_map
#         )
#       end

#       def credentials(filter = {})
#         @user_credentials ||= elektron_identity.get('credentials', filter)
#                                                .map_to(
#                                                  'body.credentials',
#                                                  &os_credential_map
#                                                )
#       end
#     end
#   end
# end
