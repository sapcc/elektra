module ModalHelper

  # Like simple_form_for(), but includes all the boilerplate for a modal dialog as well.
  # Buttons "Submit" and "Cancel" are added automatically. The following options need to be provided for this:
  #
  #     cancel_url    - where the "Cancel" button should go when the dialog is opened in a non-modal window
  #     submit_action - caption for the "Submit" button -> give this as second position argument
  #
  def simple_modal_form_for(model_object, submit_action, options={}, &block)
    # check mandatory options
    raise ArgumentError, 'submit_action missing' unless submit_action.is_a?(String)
    raise ArgumentError, 'cancel_url missing'    unless options.has_key?(:cancel_url)
    cancel_url = options.delete(:cancel_url)

    # set some options that are required for the simple_form_for() to work inside a modal dialog
    options[:remote] = request.xhr? unless options.has_key?(:remote)

    html_hash =   options[:html] ||= {}
    data_hash = html_hash[:data] ||= {}
    data_hash[:modal] = true unless data_hash.has_key?(:modal)

    # the actual work is done in a layout; the helper is just there to resemble simple_form_for()
    render(layout: 'simple_modal_form', locals: {
      model_object:  model_object,
      submit_action: submit_action,
      options:       options,
      cancel_url:    cancel_url,
    }, &block)
  end

end
