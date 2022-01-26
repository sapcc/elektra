$(
  () -> 

    emailSource  = 'select[id="templated_email_source"]'
    emailToAddr  = 'textarea[id="templated_email_to_addr"]'
    emailCcAddr  = 'input[id="templated_email_cc_addr"]'
    emailBccAddr = 'input[id="templated_email_bcc_addr"]'
    emailReplyTo = 'select[id="templated_email_reply_to_addr"]'
    emailTemplateName  = 'select[id="templated_email_template_name"]'
    emailTemplateData = 'textarea[id="templated_email_template_data"]'
    emailConfigSetName = 'select[id="templated_email_configset_name"]'
    templatedEmailForm = 'form[id="form_templated_email"]'
    labelSource = 'label[for="templated_email_source"]'


    # Test data
    source = "development.solution03@gmail.com"
    replyTo = "development.solution03@gmail.com"
    toAddresses = "sirajudheenam@gmail.com, buzzmesam@gmail.com" 
    ccAddresses = "sirajudheenam@gmail.com, buzzmesam@gmail.com"
    bccAddresses = "sirajudheenam@gmail.com, buzzmesam@gmail.com"
    templateName = "Preferences"
    configsetName = "config_set_5"
    templateData = """
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
      $(emailConfigSetName).val configsetName

    #  templated_email form handling
    $('body.emails.modal-open').on( "click", (e) ->
      # console.log "Click event detected on Form"
      # console.log e
      $(labelSource).on( "click", () -> 
        # console.log "H4 clicked"
        loadTestData()
      )
    )
)