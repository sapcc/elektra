# This class is used by ShowException middleware. See config/environments/production.rb 
class ErrorsController < ActionController::Base
  layout 'errors'

  def show
    @exception         = env['action_dispatch.exception']
    @exception_wrapper = ActionDispatch::ExceptionWrapper.new(env, @exception)
    @status_code       = @exception_wrapper.status_code
    @rescue_response   = ActionDispatch::ExceptionWrapper.rescue_responses[@exception.class.name]

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
      token       = env['action_dispatch.request_id'] || "n/a"
      description = "There are no further details available. Good luck!"

      I18n.with_options scope: [:exception, :show, @rescue_response], name: name, message: message, token: token do |i18n|
        h[:title]       = i18n.t("#{key}.title",       default: i18n.t(:title,       name)).html_safe
        h[:subtitle]    = i18n.t("#{key}.subtitle",    default: i18n.t(:subtitle,    message)).html_safe
        h[:description] = i18n.t("#{key}.description", default: i18n.t(:description, description)).html_safe
      end

      h[:env]       = env
      h[:name]      = @exception.class.name
      h[:message]   = @exception.message
      h[:token]     = token
      h[:backtrace] = @exception_wrapper.application_trace.join("\n")
      h[:source]    = @exception.respond_to?(:annoted_source_code) ? @exception.annoted_source_code : ""
    end
  end
  helper_method :details

end