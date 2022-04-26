$(
  () ->
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
