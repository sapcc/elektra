$(
  () ->
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
    templates_modal = 'body.templates.modal-open'

    html_input = $(templates_modal).find('textarea[id="tmpl_html_part"]')
    text_input = 'textarea[id="tmpl_text_part"]'
    sample_json = 'form[id="tmpl_sample_json"]'

    $(templates_modal).on('click', () ->
      console.log 'template is clicked'
      # console.log(template_html_part)
      # console.log(template_text_part)
      # console.log(template_json_content)
    )
)
