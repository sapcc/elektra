# frozen_string_literal: true

# This class guarantees that the user is logged in and his token is rescoped.
# All subclasses which require a logged in user should inherit from this class.
class DashboardController < ::ApplicationController
  include UrlHelper
  include Rescue
  # include instance methods from ScopeHandler
  include ScopeHandler
  # include instance methods from TermsOfUse
  include TermsOfUse

  # set the after_login param to be used in case of redirect after login
  # src: app/controllers/concerns/scope_handler.rb
  prepend_before_action :set_after_login_url

  # first of all determine the scope of the user by the domain and project id
  # which are passed as params and could be friendly ids, id or names.
  before_action :identify_scope, except: :terms_of_use

  authentication_required domain: ->(c) { c.instance_variable_get(:@scoped_domain_id) },
                          domain_name: ->(c) { c.instance_variable_get(:@scoped_domain_name) },
                          project: lambda { |c|
                            c.instance_variable_get(:@scoped_project_id)
                          },
                          rescope: false,
                          two_factor: :two_factor_required?,
                          except: :terms_of_use

  # after_login is used by monsoon_openstack_auth gem.
  # After the authentication process has finished the
  # after_login can be removed.
  before_action :remove_after_login_url

  # check if user has accepted terms of use.
  # Otherwise it is a new, unboarded user.
  before_action :check_terms_of_use,
                except: %i[accept_terms_of_use terms_of_use]

  # rescope token
  before_action :rescope_token, except: [:terms_of_use]

  before_action :load_webcli_endpoint, except: %i[terms_of_use]
  before_action :ensure_user_friendly_url, except: %i[terms_of_use]
  before_action :load_active_project

  before_action :raven_context, except: [:terms_of_use]
  before_action :set_mailer_host

  before_action :load_help_text

  # The `authentication_required` action ensures the user is logged in,
  # but without specific scope. This confirms the user's existence and validates the token.
  # The next step is to rescope the token to the requested domain and project.
  # Before rescoping, the user must accept the terms of use, which is why the
  # `check_terms_of_use` action is called prior to `rescope_token`.
  #
  # Summary: The user is logged in, has accepted the terms of use, and the token is rescoped.
  def rescope_token
    authentication_rescope_token
  rescue MonsoonOpenstackAuth::Authentication::NotAuthorized => e
    if e.message =~ /has no access to the requested scope/
      if @scoped_project_id.present?
        render(template: 'application/exceptions/unauthorized')
      elsif @scoped_domain_id.present?
        authentication_rescope_token(domain: nil, project: nil)
      end
    end
    # All other NotAuthorized Errors handled by "rescue_and_render_exception_page"
  end

  def two_factor_required?
    if ENV['TWO_FACTOR_AUTH_DOMAINS']
      @two_factor_required =
        ENV['TWO_FACTOR_AUTH_DOMAINS']
        .gsub(/\s+/, '')
        .split(',')
        .include?(@scoped_domain_name)
      return @two_factor_required
    end
    false
  end

  protected

  def show_beta?
    params[:betafeatures] == 'showme'
  end

  helper_method :show_beta?

  def raven_context
    @sentry_user_context =
      {
        ip_address: request.ip,
        id: current_user.id,
        email: current_user.email,
        username: current_user.name,
        domain: current_user.user_domain_name,
        name: current_user.full_name
      }.reject { |_, v| v.nil? }

    Raven.user_context(@sentry_user_context)

    tags = {}
    tags[:request_id] = request.uuid if request.uuid
    tags[:plugin] = plugin_name if try(:plugin_name).present?
    if current_user.domain_id
      tags[:domain_id] = current_user.domain_id
      tags[:domain_name] = current_user.domain_name
    elsif current_user.project_id
      tags[:project_id] = current_user.project_id
      tags[:project_name] = current_user.project_name
      tags[:project_domain_id] = current_user.project_domain_id
      tags[:project_domain_name] = current_user.project_domain_name
    end
    @sentry_tags_context = tags
    Raven.tags_context(tags)
  end

  def load_webcli_endpoint
    @webcli_endpoint = current_user.service_url('webcli')
  end

  def reset_last_request_cache
    session[:last_request_timestamp] = nil
    session[:last_user_id] = nil
  end

  def set_mailer_host
    ActionMailer::Base.default_url_options[:host] = request.host_with_port
    ActionMailer::Base.default_url_options[:protocol] = request.protocol
  end

  def project_id_required
    return unless params[:project_id].blank?

    raise Core::Error::ProjectNotFound,
          'The project you have requested was not found.'
  end

  def load_help_text
    plugin_path = params[:controller]

    plugin_index =
      Core::PluginsManager.available_plugins.find_index do |p|
        plugin_path.starts_with?(p.name)
      end

    plugin = Core::PluginsManager.available_plugins.fetch(plugin_index, nil) unless plugin_index.blank?

    return if plugin.blank?

    # get name of the specific service inside the plugin
    # remove plugin name from path
    path = plugin_path.split('/')
    path.shift
    service_name = path.join('_')

    # try to find the help file, check first for service specific help file,
    # next for general plugin help file
    help_file = File.join(plugin.path, "plugin_#{service_name}_help.md")
    help_file = File.join(plugin.path, 'plugin_help.md') unless File.exist?(help_file)

    # try to find the links file, check first for service specific links file,
    # next for general plugin links file
    help_links = File.join(plugin.path, "plugin_#{service_name}_help_links.md")
    help_links = File.join(plugin.path, 'plugin_help_links.md') unless File.exist?(help_links)

    # load plugin specific help text
    @plugin_help_text = File.new(help_file, 'r').read if File.exist?(help_file)
    return unless File.exist?(help_links)

    # load plugin specific help links
    @plugin_help_links = File.new(help_links, 'r').read
    @plugin_help_links = @plugin_help_links.gsub('#{@sap_docu_url}', sap_url_for('documentation'))
  end
end
