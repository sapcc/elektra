updateWizardPage=(url) ->
  $.ajax
    url: url,
    method: 'GET',
    dataType: 'script'

$ ->
  $('*[data-wizard-action-button="true"]').click (e) ->
    $(this).replaceWith '<span class="spinner pull-right"></span>'

  $wizardContainer = $('[data-wizard-update-url]')
  url = $wizardContainer.data('wizardUpdateUrl')
  $('body').on 'hidden.bs.modal', ':not(.modal)', () ->
    updateWizardPage(url) if url
