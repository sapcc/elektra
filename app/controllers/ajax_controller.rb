# frozen_string_literal: true
# for ajax calls we do not need permission check and all other checks done by
# Dashboard Controller. So we use Scope Controller with authentication

class AjaxController < ::ScopeController
  include Rescue

  authentication_required domain: ->(c) {
                            c.instance_variable_get(:@scoped_domain_id)
                          },
                          domain_name: ->(c) {
                            c.instance_variable_get(:@scoped_domain_name)
                          },
                          project: ->(c) {
                            c.instance_variable_get(:@scoped_project_id)
                          },
                          rescope: true
end
