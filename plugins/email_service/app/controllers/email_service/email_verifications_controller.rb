module EmailService
  class EmailVerificationsController < ::EmailService::ApplicationController
    # before_action :restrict_access
    # before_action :check_ec2_creds_cronus_status
    before_action :verified_email, only: %i[new create]
    
    authorization_context 'email_service'
    authorization_required

    def index
      items_per_page = 10
      @paginatable_emails = Kaminari.paginate_array(email_addresses, total_count: email_addresses.count).page(params[:page]).per(items_per_page)
      rescue Elektron::Errors::ApiResponse => e
        flash[:error] = "Status Code: #{e.code} : Error: #{e.message}"
      rescue Exception => e
        flash[:error] = "Status Code: 500 : Error: #{e.message}"      
    end

    def new;end
    
    def show;end



    def create
      identity_values = @verified_email.process(EmailService::VerifiedEmail)
      msg = ""
      if !@verified_email.valid?
        render :new and return
      else
        identities = process_email_verification(identity_values)
        identities.each do | id |
          msg+= "#{id[:message]}; "
        end
        flash[:warning] = msg
        redirect_to plugin('email_service').email_verifications_path and return
      end
    end

    def destroy
      identity = params[:identity] unless params[:identity].nil?
      status = remove_verified_identity(identity)
      # @all_emails = list_verified_identities("EmailAddress")
      # @verified_emails = get_verified_identities_by_status(@all_emails, "Success")
      if status == "success"
        msg = "The identity #{identity} is removed"
        flash[:success] = msg
      else 
        msg = "Identity #{identity} removal failed : #{status}"
        flash[:error] = msg
      end
      redirect_to plugin('email_service').email_verifications_path 
    end


    def process_email_verification(identity_values)
      identities = []
      if identity_values['identity'].length.positive?
        identity_values['identity'].each do | id |
          status = get_identity_verification_status(id.strip, "EmailAddress")
          if status == "success"
            identities << { identity: id, status: status, message: "#{id} is already verfied" }
          elsif status == "pending"
            identities << { identity: id, status: status, message: "verification email is already send to : #{id}, please click on the activation link" }
          elsif status == "failed"
            status = verify_identity(id, "EmailAddress")
            identities << { identity: id, status: status, message: "verification is failed for #{id}. Another verification link is sent to #{id}." }
          else
            status = verify_identity(id, "EmailAddress")
            identities << { identity: id, status: status, message: "verification email is sent to #{id}. Please click on the activation link." }
          end
        end
      end
      return identities
    end

    private

      def email_verification_params
        if params.include?(:verified_email)
          return params.require(:verified_email).permit(:identity)
        else
          {}
        end
      end

      def email_verification_form(attributes={})
        EmailService::Forms::VerifiedEmail.new(attributes)
      end

      def verified_email
        @verified_email = email_verification_form(email_verification_params)
      end
      
  end
end