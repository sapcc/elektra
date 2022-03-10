
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
source = "development.solution03@gmail.com"
replyTo = "development.solution03@gmail.com"
toAddresses = "sirajudheenam@gmail.com, buzzmesam@gmail.com" 
ccAddresses = "sirajudheenam@gmail.com, buzzmesam@gmail.com"
bccAddresses = "sirajudheenam@gmail.com, buzzmesam@gmail.com"
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

@loadTestData = () ->
  $(emailSource).val source
  $(emailToAddr).val toAddresses
  $(emailCcAddr).val ccAddresses
  $(emailBccAddr).val bccAddresses
  $(emailReplyTo).val replyTo
  $(emailTemplateName).val templateName
  $(emailTemplateData).val templateData

@switch_template=(event) ->
  value = event.target.value
  if value == 'Preferences'
    $(txtTemplateData).val sampleTemplateData

$(document).on 'modal:contentUpdated', () ->
  $(document).on 'change','select[data-toggle="templateSwitch"]', switch_template
