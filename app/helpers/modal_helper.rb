module ModalHelper
  # Like simple_form_for(), but includes all the boilerplate for a modal dialog as well.
  # Button "Cancel" is added automatically. The following options can be provided for this:
  #
  #     cancel_url    - mandatory: where the "Cancel" button should go when the dialog is opened in a non-modal window
  #     submit_action - optional: adds a "Submit" button, change its caption by passing a string value
  #
  def simple_modal_form_for(model_object, options = {}, &block)
    # check mandatory options
    raise ArgumentError, "cancel_url missing" unless options.key?(:cancel_url)
    cancel_url = options.delete(:cancel_url)

    submit_action = options.delete(:submit_action)
    # default submit caption
    submit_action = "Submit" if submit_action && !submit_action.is_a?(String)

    # set some options that are required for the simple_form_for() to work inside a modal dialog
    options[:remote] = request.xhr? unless options.key?(:remote)

    html_hash = options[:html] ||= {}
    data_hash = html_hash[:data] ||= {}
    data_hash[:modal] = true unless data_hash.key?(:modal)

    # the actual work is done in a layout; the helper is just there to resemble simple_form_for()
    render(
      layout: "simple_modal_form",
      locals: {
        model_object: model_object,
        submit_action: submit_action,
        options: options,
        cancel_url: cancel_url,
        cancel_text: options.fetch(:cancel_text, "Cancel"),
      },
      &block
    )
  end
end
