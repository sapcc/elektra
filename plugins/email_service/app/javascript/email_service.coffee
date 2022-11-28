# email_source
switch_source_type=(event) ->
  value = event.target.value
  if value == 'email'
    $('#email-source').removeClass('hide')
    $('#domain-source').addClass('hide')
    $('#domain-source-name').addClass('hide')
  else if value == 'domain'
    $('#domain-source').removeClass('hide')
    $('#domain-source-name').removeClass('hide')
    $('#email-source').addClass('hide')

populate_email_addresses=(event) ->
  value = event.target.value
  console.log "email address is changed: " + value
  $('#plain_email_reply_to_addr').val(value)

populate_domain_addresses=(event) ->
  value = event.target.value
  console.log "domain address is changed: " + value
  $('#plain_email_source_domain').val(value)

set_domain_suffix=(event) ->
  value = event.target.value
  console.log "domain change detected"
  $('#domain-source-name').val(value)
  # console.log $('textarea[id="plain_email_html_body"]').val
  # console.log $('textarea[id="plain_email_text_body"]').val

# plain_email
sourceDomainNamePart = 'input[id="plain_email_source_domain_name_part"]'
switch_domain_name=(event) ->
  value = event.target.value
update_name_part=(event) ->
  value = event.target.value

# templated_email
emailSource  = 'select[id="templated_email_source"]'
emailToAddr  = 'textarea[id="templated_email_to_addr"]'
emailCcAddr  = 'input[id="templated_email_cc_addr"]'
emailBccAddr = 'input[id="templated_email_bcc_addr"]'
emailReplyTo = 'select[id="templated_email_reply_to_addr"]'
selectTemplateName  = 'select[id="templated_email_template_name"]'
txtTemplateData = 'textarea[id="templated_email_template_data"]'
emailConfigSetName = 'select[id="templated_email_configset_name"]'
templatedEmailForm = 'form[id="form_templated_email"]'
labelSource = 'label[for="templated_email_source"]'
labelTemplateData = 'label[for="templated_email_template_data"]'

# Test data
source = "fake3@example.com"
replyTo = "fake3@example.com"
toAddresses = "fake1@example.com, fake2@example.com"
ccAddresses = "fake1@example.com, fake2@example.com"
bccAddresses = "fake1@example.com, fake2@example.com"
templateName = "Preferences"
configsetName = "config_set_5"
sampleTemplateData = """
{
  "meta":{
    "userId":"575132908"
  },
  "contact":{
    "firstName":"Michael",
    "lastName":"Jackson",
    "city":"Texas",
    "country":"USA",
    "postalCode":"78974"
  },
  "subscription":[
    {
      "interest":"Sports"
    },
    {
      "interest":"Travel"
    },
    {
      "interest":"Cooking"
    }
  ]
}
"""

loadTestData = () ->
  $(emailSource).val source
  $(emailToAddr).val toAddresses
  $(emailCcAddr).val ccAddresses
  $(emailBccAddr).val bccAddresses
  $(emailReplyTo).val replyTo
  $(emailTemplateName).val templateName
  $(emailTemplateData).val templateData

switch_template=(event) ->
  value = event.target.value
  if value == 'Preferences_template'
    $(txtTemplateData).val sampleTemplateData

validateTemplateData=(event) ->
  value = event.target.value
  if value == ""
    console.log "Template data can't be empty"

loadSampleToAddress=(event) ->
  value = event.target.value
  if value == "fake2@example.com"
    $(emailToAddr).val "fake1@example.com"
    console.log "fake2@example.com is loaded"
    console.log "fake1@example.com is populated"

# switch DKIM type
switch_dkim_type=(event) ->
  value = event.target.value
  if value == 'byo_dkim'
    $('#byo_dkim').removeClass('hide')
    $('#easy_dkim').addClass('hide')
  else if value == 'easy_dkim'
    $('#easy_dkim').removeClass('hide')
    $('#byo_dkim').addClass('hide')

# verify identity
verify_identity = 'input[id="verified_email_identity"]'

validate_identity=(event) ->
  value = event.target.value
  console.log "entered email address is : " + value

$(document).on 'modal:contentUpdated', () ->
  # email_source
  # handler to switch source type between email and domain
  $(document).on 'change','select[data-toggle="sourceSwitch"]', switch_source_type
  # $(document).on 'click','#domain-source-name', set_domain_suffix
  # $(document).on 'change','select[id="plain_email_source_email"]', populate_email_addresses
  # $(document).on 'change','select[id="plain_email_source_domain"]', populate_domain_addresses

  # plain_email
  $(document).on 'change click', sourceDomainNamePart, update_name_part
  $(document).on 'change','select[data-toggle="sourceDomainSelect"]', switch_domain_name

  # templated_email
  $(document).on 'change','select[data-toggle="templateSwitch"]', switch_template
  $(document).on 'change','select[data-toggle="emailSelect"]', loadSampleToAddress
  $(document).on 'blur','textarea[id="templated_email_template_data"]', validateTemplateData
  # verify identity
  $(document).on 'change click', 'input[id="verified_email_identity"]', validate_identity
  # console.log "inside model content updated"

  # create_email_identity_domain
  # handler to switch source type between email and domain
  $(document).on 'change','select[data-toggle="dkimTypeSwitch"]', switch_dkim_type


$(
  () ->

    # settings
    secret_key = $("div#settings-pane").find('table').children().find('tr').find('#td_secret_key')
    secret_key_val = secret_key.html()
    btn_tg_secret = $("div#settings-pane").find('table').children().find('tr').find("button#btn_tg_secret")
    secret_key_x_val = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    eye = btn_tg_secret.find('#eye')
    eye_slash = btn_tg_secret.find('#eye_slash')
    isHidden = true
    eye.show()
    eye_slash.hide()
    $(secret_key).html(secret_key_x_val)
    $(btn_tg_secret).on('click',
      () =>
        if isHidden
          $(secret_key).html(secret_key_val)
          eye_slash.show()
          eye.hide()
          isHidden = !isHidden
        else
          $(secret_key).html(secret_key_x_val)
          eye.show()
          eye_slash.hide()
          isHidden = !isHidden
    )

    # templates
    template_name = "Preference_Template"
    template_subject = "Preferences"
    template_html_part = """
      <!doctype html>
      <html>
        <head><meta charset='utf-8'></head>
        <body>
          <h1>Your Preferences</h1>
          <h2>Dear {{ name.lastName }}, </h2>
          <p> You have indicated that you are interested in receiving information about the following topics:</p>
          <ul>{{#each subscription}}
            <li>{{interest}}</li>
            {{/each}}
          </ul>
          <p>You can change these settings at any time by visiting the <a href=https://www.abc.xyz/preferences/i.aspx?id={{meta.userId}}> Preference Center</a>.</p>
        </body>
      </html>
    """
    template_text_part = """
      Your Preferences
      Dear {{ name.lastName }},
      You have indicated that you are interested in receiving information about the following topics:.
      {{#each subscription}}
        {{interest}}
      {{/each}}
      You can change these settings at any time by visiting
      the Preference Center https://www.abc.xyz/preferences/i.aspx?id={{meta.userId}}.
    """

    template_json_content = """
        {
          "meta":{
            "userId":"575132908"
          },
          "contact":{
            "firstName":"Michael",
            "lastName":"Jackson",
            "city":"Texas",
            "country":"USA",
            "postalCode":"78974"
          },
          "subscription":[
            {
              "interest":"Sports"
            },
            {
              "interest":"Travel"
            },
            {
              "interest":"Cooking"
            }
          ]
        }
    """
    templatesModal = 'body.templates.modal-open'
    templateForm = 'form[id="form_template"]'
    name = 'input[id="template_name"]'
    subject = 'input[id="template_subject"]'
    html_input = 'textarea[id="template_html_part"]'
    text_input = 'textarea[id="template_text_part"]'
    labelTemplateName = 'label[for="template_name"]'

    loadTestData = () ->
      $(name).val template_name
      $(subject).val template_name
      $(html_input).val template_html_part
      $(text_input).val template_text_part

    $(templatesModal).on('click', () ->
      $(labelTemplateName).on( "click", () ->
        loadTestData()
      )
    )
)
