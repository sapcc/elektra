# This module is used to check if the user has accepted the terms of use.
module TermsOfUse
  def check_terms_of_use
    @orginal_url = request.original_url
    return if tou_accepted?

    render action: :accept_terms_of_use
  end

  def accept_terms_of_use
    if params[:terms_of_use]
      # user has accepted terms of use -> save the accepted version in the domain profile
      # 30.03.2021: change domain_profiles.create to create! so that an exception is thrown in case something goes wrong (would have saved me a day of debugging if we had had that)
      UserProfile
        .create_with(
          name: current_user.name,
          email: current_user.email,
          full_name: current_user.full_name
        )
        .find_or_create_by(uid: current_user.id)
        .domain_profiles
        .create!(
          tou_version: Settings.actual_terms.version,
          domain_id: current_user.user_domain_id
        )

      reset_last_request_cache
      # redirect to original path, this is the case after the TOU view
      if params[:orginal_url]
        redirect_to params[:orginal_url]
      elsif plugin_available?('identity')
        redirect_to main_app.domain_home_path(domain_id: @scoped_domain_fid)
      else
        redirect_to main_app.root_path
      end
    else
      check_terms_of_use
    end
  end

  def terms_of_use
    if current_user
      @tou =
        UserProfile.tou(
          current_user.id,
          current_user.user_domain_id,
          Settings.actual_terms.version
        )
    end
    render action: :terms_of_use
  end

  def tou_accepted?
    # Consider that every plugin controller inhertis from dashboard controller
    # and check_terms_of_use method is called on every request.
    # In order to reduce api calls we cache the result of new_user?
    # in the session for 5 minutes.
    is_cache_expired =
      current_user.id != session[:last_user_id] ||
      session[:last_request_timestamp].nil? ||
      (session[:last_request_timestamp] < Time.now - 5.minute)
    if is_cache_expired
      session[:last_request_timestamp] = Time.now
      session[:last_user_id] = current_user.id
      session[:tou_accepted] = UserProfile.tou_accepted?(
        current_user.id,
        current_user.user_domain_id,
        Settings.actual_terms.version
      )
    end

    session[:tou_accepted]
  end
end
