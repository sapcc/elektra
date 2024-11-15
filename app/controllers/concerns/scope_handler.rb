# Description: This module is used to handle the scope of the domain and project.
module ScopeHandler
  # set the after_login param to be used in case of user has to be redirected to login page
  def set_after_login_url
    return if params[:after_login]

    requested_url = request.env['REQUEST_URI']
    referer_url = request.referer
    referer_url =
      begin
        "#{URI(referer_url).path}?#{URI(referer_url).query}"
      rescue StandardError
        nil
      end

    params[:after_login] = if requested_url =~ /(\?|&)modal=true/ && referer_url =~ /(\?|&)overlay=.+/
                             referer_url
                           else
                             requested_url
                           end
  end

  # remove the after_login param after user is authenticated
  def remove_after_login_url
    params.delete(:after_login)
  end

  # this method is called before the user is authenticated.
  # We try to get the domain and project from the friendly_id_entry table.
  # If the friendly_id_entry is not found, then it is the first time the user
  # is accessing the domain or project. Otherwise, we redirect the user to the friendly id.
  def identify_scope
    @scoped_domain_id = @scoped_domain_name = @scoped_domain_fid = params[:domain_id]
    @scoped_project_id = @scoped_project_name = @scoped_project_fid = params[:project_id]

    # try to find friendly entry for domain
    domain_fid = get_domain_fid(@scoped_domain_id)

    if domain_fid
      @scoped_domain_id = domain_fid.key
      @scoped_domain_name = domain_fid.name
      @scoped_domain_fid = domain_fid.slug
    end

    if @scoped_domain_id && @scoped_project_id

      project_fid = get_project_fid(@scoped_domain_id, @scoped_project_id)

      if project_fid

        @scoped_project_id = project_fid.key
        @scoped_project_name = project_fid.name
        @scoped_project_fid = project_fid.slug
      end
    end

    redirect_to_user_friendly_url(@scoped_domain_fid, @scoped_project_fid)

    @policy_default_params = { target: {} }
    @policy_default_params[:target][:scoped_domain_name] = @scoped_domain_name
    @policy_default_params[:target][:scoped_project_name] = @scoped_project_name

    @can_access_domain = !@scoped_domain_name.nil?
    @can_access_project = !@scoped_project_name.nil?
  end

  # this method is called after the user is authenticated
  # We have to redirect to friendly id of domain because
  # the session cookie sets the domain as path to ensure
  # different session for different domains.
  # So if in the identify_scope method user was redirected, so we have to redirect now
  # to the friendly id of domain.
  def ensure_user_friendly_url
    project_id = current_user.project_id
    project_name = current_user.project_name
    domain_id = current_user.domain_id || current_user.project_domain_id
    domain_name = current_user.domain_name || current_user.project_domain_name

    @domain_config = DomainConfig.new(domain_name || params[:domain_id])
    byebug
    # do nothing if domain_id is empty what means there is not scope
    return unless domain_id

    # this config is needed for the bedrock context
    # do not allow to access hidden plugins
    redirect_to '/error-404' and return if @domain_config.plugin_hidden?(plugin_name.to_s)

    if project_id
      project_fid = FriendlyIdEntry.find_or_create_entry(
        'Project', domain_id, project_id, project_name
      )
    end

    domain_fid = FriendlyIdEntry.find_or_create_entry('Domain', nil, domain_id, domain_name)
    redirect_to_user_friendly_url(domain_fid&.slug, project_fid&.slug)
  end

  # load active project based on logged in user
  def load_active_project
    return unless current_user&.project_id

    # load active project. Try first from ObjectCache and then from API by id or name
    cached_project = ObjectCache.where(id: current_user.project_id).first
    @active_project = Identity::Project.new(services.identity, cached_project.payload) if cached_project
    return unless @active_project.nil?

    @active_project = services.identity.find_project(current_user.project_id)
    # @active_project = services.identity
    #                           .projects(domain_id: @domain&.id, name: params[:project_id])
    #                           .first
    return unless @active_project.present?

    ObjectCache.new(name: @active_project.name, id: @active_project.id, payload: @active_project.attributes).save
  end

  protected

  def redirect_to_user_friendly_url(domain_fid, project_fid)
    current_path = request.path
    if params[:project_id]
      current_path = current_path.gsub(%r{^/[^/]+/[^/]+/}, "/#{domain_fid}/#{project_fid}/")
    elsif params[:domain_id]
      current_path = current_path.gsub(%r{^/#{params[:domain_id]}/}, "/#{domain_fid}/")
    end

    redirect_to current_path if current_path != request.path
  end

  def get_domain_fid(domain_id)
    FriendlyIdEntry.find_by_class_scope_and_key_or_slug('Domain', nil, domain_id)
  end

  def get_project_fid(domain_id, project_id)
    FriendlyIdEntry.find_by_class_scope_and_key_or_slug('Project', domain_id, project_id)
  end
end
