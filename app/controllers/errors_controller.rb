# This class is used by ShowException middleware. See config/environments/production.rb
class ErrorsController < ActionController::Base
  include CurrentUserWrapper
  layout 'plain'

  def error_404
    render action: :page_not_found
  end

  def show
    bc = ActiveSupport::BacktraceCleaner.new
    bc.add_filter   { |line| line.gsub(Rails.root.to_s, '') } # strip the Rails.root prefix
    bc.add_silencer { |line| line =~ /puma|rubygems/ } # skip any lines from puma or rubygems

    @exception         = request.env['action_dispatch.exception']
    @exception_wrapper = ActionDispatch::ExceptionWrapper.new(bc, @exception)
    @status_code       = @exception_wrapper.status_code
    @rescue_response   = ActionDispatch::ExceptionWrapper.rescue_responses[@exception.class.name]
    @sentry_event_id   = Raven.last_event_id
    @sentry_user_context = if current_user
      {
        ip_address: request.ip,
        id: current_user.id,
        email: current_user.email,
        username: current_user.name,
        domain: current_user.user_domain_name,
        name: current_user.full_name
      }.reject {|_,v| v.nil?}
    else
      {}
    end

    respond_to do |format|
      format.html { render :show, status: @status_code, layout: !request.xhr? }
      format.json { render json: {error: details}, status: @status_code }
    end
  end

  protected

  def debug_visible?
    params[:debug]
  end
  helper_method :debug_visible?

  def details
    @details ||= {}.tap do |h|
      key         = @exception.class.name.underscore
      name        = @exception.class.name
      message     = @exception.message
      token       = Raven.last_event_id || request.uuid || "n/a"
      description = "There are no further details available. Sorry!"

      I18n.with_options scope: [:exception, :show, @rescue_response], name: name, message: message, token: token do |i18n|
        h[:title]       = i18n.t("#{key}.title",       default: name).html_safe
        h[:subtitle]    = i18n.t("#{key}.subtitle",    default: message).html_safe
        h[:description] = i18n.t("#{key}.description", default: description).html_safe
      end

      h[:env]       = request.env
      h[:name]      = @exception.class.name
      h[:message]   = @exception.message
      h[:token]     = token
      h[:backtrace] = @exception_wrapper.application_trace.join("\n")
      h[:source]    = @exception.respond_to?(:annoted_source_code) ? @exception.annoted_source_code : ""
    end
  end
  helper_method :details

end
