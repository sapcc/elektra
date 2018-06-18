module Identity
  module RestrictedRoles
    def available_roles
      roles = if current_user.is_allowed?('cloud_admin')
                services.identity.roles.sort_by(&:name)
              else
                service_user.identity.roles.keep_if do |role|
                  ALLOWED_ROLES.include?(role.name) ||
                    (current_user.has_role?(role.name) &&
                      BETA_ROLES.include?(role.name))
                end
              end

      roles.each do |role|
        role.description = I18n.t(
          "roles.#{role.name}", default: role.name.try(:titleize)
        ) + " (#{role.name})"
      end
    end
  end
end
