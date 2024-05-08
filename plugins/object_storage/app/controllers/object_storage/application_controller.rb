# frozen_string_literal: true

module ObjectStorage
  class ApplicationController < ::DashboardController
    def show
      @service_name = params[:service_name]
    end

    def check_acls
      read_acl_string = params[:read] || ""
      write_acl_string = params[:write] || ""

      read_acls = parse_acl(read_acl_string)
      write_acls = parse_acl(write_acl_string)
      render json: { read: read_acls, write: write_acls }
    end

    private

    def parse_acl(acl_string = "")
      # remove all \n
      acl_string.delete!("\n")
      # https://docs.openstack.org/swift/latest/overview_acl.html#container-acls
      @acl_parse_error = false
      acl_data = {}
      acls = acl_string.split(",")
      acls.each do |acl|
        case acl
        # standard reading cases
        when ".rlistings"
          acl_data[acl] = {
            type: ".rlistings",
            operation: "access",
            user: "Listing",
            project: "ANY",
            token: false,
          }
        when ".r:*"
          acl_data[acl] = {
            type: ".r:*",
            operation: "referer",
            user: "ANY",
            project: "ANY",
            token: false,
          }
        else
          # all other special cases
          acl_parts = acl.split(":", 2) # use split limit 2, this is needed because of "http://" in referer
          if acl_parts.length == 2
            case acl_parts[0]
            when ".r"
              type = ".r:<referer>"
              user = acl_parts[1]
              operation = "referer"
              if acl_parts[1].start_with? "-"
                acl_parts[1].slice!(0)
                type = ".r:-<referer>"
                user = acl_parts[1]
                operation = "referer denied"
              end

              acl_data[acl] = {
                type: type,
                operation: operation,
                user: user,
                project: "ANY",
                referer: acl_parts[1],
                token: false,
              }
            else
              # *:*
              if acl_parts[0] == "*" && acl_parts[1] == "*"
                acl_data[acl] = {
                  type: ".*:*",
                  operation: nil,
                  user: "ANY user",
                  project: "ANY",
                  token: true,
                }
                # <project-id>:<user-id>
              elsif acl_parts[0] != "*" and acl_parts[1] != "*"
                project = cloud_admin.identity.find_project(acl_parts[0])
                user = cloud_admin.identity.find_user(acl_parts[1])
                unless user.nil? || project.nil?
                  user_domain = cloud_admin.identity.find_domain(user.domain_id)
                  domain = cloud_admin.identity.find_domain(project.domain_id)
                  acl_data[acl] = {
                    type: "<project-id>:<user-id>",
                    operation: nil,
                    user: "#{user.description} (#{user_domain.name})",
                    project: "#{project.name} (#{domain.name})",
                    token: true,
                  }
                else
                  if user.nil? && project.nil?
                    acl_data[acl] = {
                      error:
                        "cannot find project with ID #{acl_parts[0]} and user with ID #{acl_parts[1]}",
                    }
                  elsif project.nil?
                    acl_data[acl] = {
                      error: "cannot find project with ID #{acl_parts[0]}",
                    }
                  elsif user.nil?
                    acl_data[acl] = {
                      error: "cannot find user with ID #{acl_parts[1]}",
                    }
                  else
                    acl_data[acl] = { error: "unknown parse error" }
                  end
                  acl_data[:error_happened] = true
                  @acl_parse_error = true
                end

                # <project-id>:*
              elsif acl_parts[0] != "*" and acl_parts[1] == "*"
                project = cloud_admin.identity.find_project(acl_parts[0])
                unless project.nil?
                  domain = cloud_admin.identity.find_domain(project.domain_id)
                  acl_data[acl] = {
                    type: "<project-id>:*",
                    operation: nil,
                    user: "ANY user",
                    project: "#{project.name} (#{domain.name})",
                    token: true,
                  }
                else
                  acl_data[acl] = {
                    error: "cannot find project with ID #{acl_parts[0]}",
                  }
                  acl_data[:error_happened] = true
                  @acl_parse_error = true
                end
                # *:<user-id>
              elsif acl_parts[0] == "*" and acl_parts[1] != "*"
                user = cloud_admin.identity.find_user(acl_parts[1])
                unless user.nil?
                  user_domain = cloud_admin.identity.find_domain(user.domain_id)
                  acl_data[acl] = {
                    type: "*:<user-id>",
                    operation: nil,
                    user: "#{user.description} (#{user_domain.name})",
                    project: "ANY",
                    token: true,
                  }
                else
                  acl_data[acl] = {
                    error: "cannot find user with ID #{acl_parts[1]}",
                  }
                  acl_data[:error_happened] = true
                  @acl_parse_error = true
                end
              end
            end
          else
            unless acl.include? ":" or acl.include? "*"
              # <role_name>
              acl_data[acl] = {
                type: "<role_name>",
                operation: nil,
                user: "ANY user with role #{acl}",
                project: "#{@scoped_project_name} (#{@scoped_domain_name})",
                token: true,
              }
            else
              acl_data[acl] = { error: "cannot parse acl" }
              acl_data[:error_happened] = true
              @acl_parse_error = true
            end
          end
        end
      end

      return acl_data
    end
  end
end
