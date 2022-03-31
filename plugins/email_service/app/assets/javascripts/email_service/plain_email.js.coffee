# # Document Ready function
# $(
#   () -> 
#     # regular expression to separate the email addresses (comma and space)
#     re = /[\s, ]+/
#     # regular expression for valid email address
#     regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
#     currentDate = new Date()

#     source_help = to_help = cc_help = bcc_help = subject_help = htmlbody_help = textbody_help = undefined
#     validToAddressCount = validCcAddressCount = validBccAddressCount =  totalEmailAddresses = 0
#     # form elements
#     emailSource  = 'select[id="plain_email_source"]'
#     emailToAddr  = 'textarea[id="plain_email_to_addr"]'
#     emailCcAddr  = 'textarea[id="plain_email_cc_addr"]'
#     emailBccAddr = 'textarea[id="plain_email_bcc_addr"]'
#     emailSubject  = 'input[id="plain_email_subject"]'
#     emailHtmlBody = 'textarea[id="plain_email_html_body"]'
#     emailTextBody = 'textarea[id="plain_email_text_body"]'
#     plainEmailForm = 'form[id="form_plain_email"]'

#     labelPlainEmailSource = 'label[for="plain_email_source"]'
#     labelPlainEmailToAddr = 'label[for="plain_email_to_addr"]'

#     # icon_hint classes
#     fg_email_source = '.form-group.plain_email_source'
#     fg_email_to_addr = '.form-group.plain_email_to_addr'
#     fg_email_cc_addr = '.form-group.plain_email_cc_addr'
#     fg_email_bcc_addr = '.form-group.plain_email_bcc_addr'
#     fg_email_subject = '.form-group.plain_email_subject'
#     fg_email_htmlbody = '.form-group.plain_email_html_body'
#     fg_email_textbody = '.form-group.plain_email_text_body'

#     # Test data
#     sender = "development.solution03@gmail.com"
#     subject = "Cronus eMail Service - from Elektra UI Plugin - #{currentDate}"
#     htmlBody = "<h1>Email Sent by Cronus </h1><p><h2>AWS SES Proxy Service</h2> <p> #{currentDate}</p>"
#     textBody = "Email Sent by Cronus - AWS SES Proxy Service #{currentDate}"
#     toRealAddresses = "sirajudheenam@gmail.com, buzzmesam@gmail.com"
#     ccRealAddresses = "sirajudheenam@gmail.com, buzzmesam@gmail.com"
#     bccRealAddresses = "sirajudheenam@gmail.com, buzzmesam@gmail.com"

#     toFakeAddresses = """ 
#       rjones@sbcglobal.net, doormat@comcast.net, less mfburgo@me.com, 
#       alfred@outlook.com, mfleming@comcast.net, verymuch hermanab@comcast.net,
#       dpitts@sbcglobal.net, care,fairbank@aol.com, moxfulder@live.com, 
#       simone@sbcglobal.net, tarreau@comcast.net,so much mal@verizon.net,
#       I,bahwi@outlook.com, jonas@optonline.net,  zeller@yahoo.ca, alias@me.com,
#       policies@att.net,froodian@hotmail.com, fmerges@att.net, tmccarth@yahoo.com,
#       curly@comcast.net, plover@me.com, jmcnamara@icloud.com, random,
#       dgriffith@comcast.net, invalid,elmer@optonline.net, lamky@yahoo.ca, 
#       barlow@sbcglobal.net,timlinux@optonline.net, anicolao@me.com, 
#       jaesenj@yahoo.ca, some,cgcra@yahoo.com, guialbu@msn.com, 
#       benits@verizon.net, entries,bwcarty@icloud.com, pavel@msn.com, 
#       pplinux@mac.com, verizon,rmcfarla@mac.com, bjornk@verizon.net, 
#       globalcampbell@verizon.net, notaprguy@verizon.net
      
#     """
#     ccFakeAddresses = """ 
#       curly@comcast.net, plover@me.com, jmcnamara@icloud.com, random,
#       dgriffith@comcast.net, invalid,elmer@optonline.net, lamky@yahoo.ca, 
#       barlow@sbcglobal.net,timlinux@optonline.net, anicolao@me.com, 
#       jaesenj@yahoo.ca, some,cgcra@yahoo.com, guialbu@msn.com, 
#       benits@verizon.net, entries,bwcarty@icloud.com, pavel@msn.com, 
#       pplinux@mac.com, verizon,rmcfarla@mac.com, bjornk@verizon., 
#       globalcampbell@verizon.net, notaprguy@verizon.net
#     """
#     bccFakeAddresses = """
#       greear@icloud.com, major,ranasta@gmail.com, forsberg@sbcglobal.net, 
#       pdbaby@verizon.net, afifi@aol.com, ninenine@verizon.net, potato 
#       mbswan@live.com, galbra@mac.com, vsprintf@hotmail.com, ducasse@att.net,
#       tomato sopwith@yahoo.ca, wildfire@yahoo.ca, donev@mac.com, minor
#       pdbaby@msn.com, gfody@hotmail.com,frederic@hotmail.com, xnormal@live.com,
#        ardagna@optonline.net, citizenl@yahoo.com, makarow@gmail.com, 
#     """

#     loadFakeData = () ->
#       $(emailSource).val sender
#       $(emailToAddr).val toFakeAddresses
#       $(emailCcAddr).val ccFakeAddresses
#       $(emailBccAddr).val bccFakeAddresses
#       $(emailSubject).val subject
#       $(emailHtmlBody).val htmlBody
#       $(emailTextBody).val textBody

#     loadRealData = () -> 
#       $(emailSource).val sender
#       $(emailToAddr).val toRealAddresses
#       $(emailCcAddr).val ccRealAddresses
#       $(emailBccAddr).val bccRealAddresses
#       $(emailSubject).val subject
#       $(emailHtmlBody).val htmlBody
#       $(emailTextBody).val textBody

#     initializeData = () ->
#       source_help = $(".form-group.email_source p").filter(".help-block")
#       to_help = $(".form-group.email_to_addr p").filter(".help-block")
#       cc_help = $(".form-group.email_cc_addr p").filter(".help-block")
#       bcc_help = $(".form-group.email_bcc_addr p").filter(".help-block")
#       subject_help = $(".form-group.email_subject p").filter(".help-block")
#       htmlbody_help = $(".form-group.email_htmlbody p").filter(".help-block")
#       textbody_help = $(".form-group.email_textbody p").filter(".help-block")
      
#     increaseTextArea = (textField ,textLength) ->
#       rows =   Math.round(textLength / 35)
#       $(textField).prop("rows", "#{rows}")

#     getHelpText = (errText, helpText) ->
#       errSpan  = if errText  then "<span class='helpSpan'>#{errText}</span>"  else ""
#       helpSpan = if helpText then "<span class='helpSpan'>#{helpText}</span>" else ""
#       return "<i class='fa fa-info-circle'></i>#{helpSpan} #{errSpan}"

#     getTotalEmailAddresses = () ->
#       totalEmailAddresses = validToAddressCount + validCcAddressCount + validBccAddressCount
#       if totalEmailAddresses > 50 
#         errorText = "emails count : #{totalEmailAddresses} is exceeding the allowed 50"

#     validateEmails = (inputElement) ->
#       validEmails   = []
#       invalidEmails = []
#       inputText = $(inputElement).val().trimEnd().trimStart()
#       $(inputElement).val(inputText);
#       if not inputText or inputText.length is 0 and totalEmailAddresses is 0
#         errorText = "At least one valid email address is required."
#       else
#         inputText.split(re).forEach (emailItem, index) => 
#           emElement = emailItem.trimEnd().trimStart()
#           if regex.test String(emElement).toLowerCase() 
#             validEmails.push emElement
#           else
#             invalidEmails.push emailItem
#         if invalidEmails.length > 0 
#           errorText = "Invalid entries: <b><em> #{invalidEmails}</em></b>."
#         if validEmails.length <= 50
#           helperText = "<b> #{validEmails.length} </b>valid email recipients of #{ (validEmails.length + invalidEmails.length) } entries."

#       switch inputElement
#         when emailToAddr
#           validToAddresses = validEmails
#           validToAddressCount = validEmails.length
#           $(to_help).show()
#           if invalidEmails.length > 0 or errorText
#             $(to_help).html( getHelpText errorText, helperText )
#             $(fg_email_to_addr).addClass('has-error')
#           else
#             $(to_help).html( getHelpText "", helperText  )
#             $(fg_email_to_addr).removeClass('has-error')
#           if validEmails.length > 0 and invalidEmails.length is 0 
#             $(to_help).hide(1000)
#         when emailCcAddr
#           $(cc_help).show()
#           validCcAddresses = validEmails
#           validCcAddressCount = validEmails.length
#           if invalidEmails.length > 0 or errorText 
#             $(cc_help).html( getHelpText errorText, helperText )
#             $(fg_email_cc_addr).addClass('has-error')
#           else
#             $(cc_help).html( getHelpText "", helperText )
#             $(fg_email_cc_addr).removeClass('has-error')
#           if validEmails.length > 0 and invalidEmails.length is 0
#             $(cc_help).hide(1000)
#         when emailBccAddr
#           validBccAddresses = validEmails
#           validBccAddressCount = validEmails.length
#           $(bcc_help).show()
#           if invalidEmails.length > 0 or errorText
#             $(bcc_help).html( getHelpText errorText, helperText )
#             $(fg_email_bcc_addr).addClass('has-error')
#           else
#             $(bcc_help).html( getHelpText "", helperText )
#             $(fg_email_bcc_addr).removeClass('has-error')
#           if validEmails.length > 0 and invalidEmails.length is 0
#             $(bcc_help).hide(1000)
#       getTotalEmailAddresses()

#     #  plain email form handling
#     # $('body.emails.modal-open').on( "click", () ->
#       # initializeData()

#       # # load real valid data to form, when source label is clicked
#       # $(labelPlainEmailSource).on("click", () -> 
#       #   loadRealData()
#       # )

#       # # load fake data to form to validate when to addr label is clicked
#       # $(labelPlainEmailToAddr).on("click", () -> 
#       #   loadFakeData()
#       # )

#       # $(emailSource).on("change blur", 
#       # () ->
#       #   source_value = $(this).val()
#       #   if not source_value and source_value.length is 0 
#       #     $(fg_email_source).addClass('has-error');
#       #     source_help.html( getHelpText "Source email can\'t be empty", "" );
#       #     source_help.show();
#       #   else
#       #     source_help.html( getHelpText  "", "valid" )
#       #     $(fg_email_source).removeClass('has-error')
#       #     source_help.hide(500);
#       # )

#       # $(emailToAddr).on("blur click", () ->
#       #   validateEmails(emailToAddr)
#       #   $(this).addClass("u-text-monospace")
#       #   $(this).css("color", "blue")
#       # )
#       # $(emailCcAddr).on("blur click", () ->
#       #   validateEmails(emailCcAddr)
#       #   $(this).addClass("u-text-monospace")
#       #   $(this).css("color", "blue")
#       # )
#       # $(emailBccAddr).on("blur click", () ->
#       #   validateEmails(emailBccAddr)
#       #   $(this).addClass("u-text-monospace")
#       #   $(this).css("color", "blue")
#       # )
#       # $(emailToAddr).on("change", () ->
#       #   increaseTextArea emailToAddr, $(this).val().length
#       # )
#       # $(emailCcAddr).on("change", () ->
#       #   increaseTextArea emailCcAddr, $(this).val().length
#       # )
#       # $(emailBccAddr).on("change", () ->
#       #   increaseTextArea emailBccAddr, $(this).val().length
#       # )
#       # $(emailSubject).on("blur click", 
#       #   () ->
#       #     $(this).addClass("u-text-monospace")
#       #     $(this).css("color", "blue")
#       #     if $(this).val().length is 0
#       #       $(fg_email_subject).addClass('has-error')
#       #       $(subject_help).html( getHelpText "<b>Subject</b> can't be empty", ""  )
#       #       $(subject_help).show()
#       #     else
#       #       $(fg_email_subject).removeClass('has-error')
#       #       $(subject_help).html( getHelpText "", "valid" )
#       #       $(subject_help).hide(1000)
#       # )
#       # $(emailHtmlBody).on("blur click", 
#       #   () ->
#       #     $(this).addClass("u-text-monospace")
#       #     $(this).css("color", "blue")
#       #     if $(this).val().length is 0 
#       #       $(fg_email_htmlbody).addClass('has-error')
#       #       $(htmlbody_help).html( getHelpText "<b>HTML Body</b> can't be empty", "" )
#       #       $(htmlbody_help).show()
#       #     else 
#       #       $(fg_email_htmlbody).removeClass('has-error')
#       #       $(htmlbody_help).html( getHelpText "", "valid" )
#       #       $(htmlbody_help).hide(1500)
#       # )
#       # $(emailTextBody).on("blur click", 
#       #   () ->
#       #     $(this).addClass("u-text-monospace")
#       #     $(this).css("color", "blue")
#       #     if $(this).val().length is 0
#       #       $(fg_email_textbody).addClass('has-error')
#       #       $(textbody_help).html( getHelpText "<b>Text Body</b> can't be empty", "" )
#       #       $(textbody_help).show()
#       #     else
#       #       $(fg_email_textbody).removeClass('has-error')
#       #       $(textbody_help).html( getHelpText "", "valid" )
#       #       $(textbody_help).hide(1500)
#       # )


#     )

# )

sourceDomainNamePart = 'input[id="plain_email_source_domain_name_part"]'
@switch_domain_name=(event) -> 
  value = event.target.value
  # $(sourceDomainNamePart).val value
  console.log value
@update_name_part=(event) -> 
  value = event.target.value 
  console.log "value is changed"

$(document).on 'modal:contentUpdated', () ->
  $(document).on 'change click', sourceDomainNamePart, update_name_part
  $(document).on 'change','select[data-toggle="sourceDomainSelect"]', switch_domain_name
   
