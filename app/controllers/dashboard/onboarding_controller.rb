module Dashboard
  class OnboardingController < ::DashboardController
    skip_before_filter :check_terms_of_use
    skip_before_filter :authentication_rescope_token
    skip_before_filter :load_user_projects
  
    # render new user template
    def new_user
    end

    # render new user template
    def new_user_request
    end

    def new_user_request_message
    end

    # onboard new user
    def register_user
      if params[:terms_of_use]
        # user has accepted terms of use -> onboard user
        Admin::OnboardingService.register_user(current_user)
        reset_last_request_cache
        # redirect to domain path
        if plugin_available?('identity')
          redirect_to plugin('identity').domain_path
        else
          redirect_to main_app.root_path
        end
      else
        render action: :new_user
      end
    end

    # new user request
    def register_user_request
      inquiry = nil

      # checkif there is an request already open (can be resubmitted via browser back)
      if services.inquiry.find_by_kind_user_states(DOMAIN_ACCESS_INQUIRY, current_user.id, ['open'])
        redirect_to :controller=>'dashboard', :action => 'new_user_request_message' and return
      end

      if params[:terms_of_use]
        processors = Admin::IdentityService.list_scope_admins(domain_id: @scoped_domain_id)
        unless processors.blank?
          inquiry = services.inquiry.inquiry_create(
              DOMAIN_ACCESS_INQUIRY,
              "Grant access for user #{current_user.full_name} to Domain #{@scoped_domain_name}",
              current_user,
              current_user.context[:user].to_json,
              processors,
              {},
              @scoped_domain_id
          )
          message = "Error during inquiry creation"
        else
          message = "Couldn't find any administrators for this domain!"
        end
      else
        message = "Please accept the terms of use!"
      end
    
      if message
        flash.now[:error] = message
        render action: :new_user_request
      else
        unless inquiry.errors?
          flash[:notice] = 'Your inquiry was send for further processing'
          redirect_to :controller=>'dashboard', :action => 'new_user_request_message'
        else
          flash.now[:error] = "Your inquiry could not be created because: #{inquiry.errors.full_messages.to_sentence}"
          render action: :new_user_request
        end
      end
    end

    def register_user_approval
      puts "register_user_approval"
    end
  end
end
