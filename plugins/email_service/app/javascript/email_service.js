/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */
// email_source
const switch_source_type = function (event) {
  const { value } = event.target;
  if (value === 'email') {
    $('#email-source').removeClass('hide');
    $('#domain-source').addClass('hide');
    return $('#domain-source-name').addClass('hide');
  } else if (value === 'domain') {
    $('#domain-source').removeClass('hide');
    $('#domain-source-name').removeClass('hide');
    return $('#email-source').addClass('hide');
  }
};

const populate_email_addresses = function (event) {
  const { value } = event.target;
  console.log(`email address is changed: ${value}`);
  return $('#plain_email_reply_to_addr').val(value);
};

const populate_domain_addresses = function (event) {
  const { value } = event.target;
  console.log(`domain address is changed: ${value}`);
  return $('#plain_email_source_domain').val(value);
};

const set_domain_suffix = function (event) {
  const { value } = event.target;
  console.log("domain change detected");
  return $('#domain-source-name').val(value);
};

// plain_email
const sourceDomainNamePart = 'input[id="plain_email_source_domain_name_part"]';
const switch_domain_name = function (event) {
  let value;
  return value = event.target.value;
};
const update_name_part = function (event) {
  let value;
  return value = event.target.value;
};

// templated_email
const emailSource = 'select[id="templated_email_source"]';
const emailToAddr = 'textarea[id="templated_email_to_addr"]';
const emailCcAddr = 'input[id="templated_email_cc_addr"]';
const emailBccAddr = 'input[id="templated_email_bcc_addr"]';
const emailReplyTo = 'select[id="templated_email_reply_to_addr"]';
const selectTemplateName = 'select[id="templated_email_template_name"]';
const txtTemplateData = 'textarea[id="templated_email_template_data"]';
const emailConfigSetName = 'select[id="templated_email_configset_name"]';
const templatedEmailForm = 'form[id="form_templated_email"]';
const labelSource = 'label[for="templated_email_source"]';
const labelTemplateData = 'label[for="templated_email_template_data"]';

// Test data
const source = "fake3@example.com";
const replyTo = "fake3@example.com";
const toAddresses = "fake1@example.com, fake2@example.com";
const ccAddresses = "fake1@example.com, fake2@example.com";
const bccAddresses = "fake1@example.com, fake2@example.com";
const templateName = "Preferences";
const configsetName = "config_set_5";
const sampleTemplateData = `\
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
}\
`;

let loadTestData = function () {
  $(emailSource).val(source);
  $(emailToAddr).val(toAddresses);
  $(emailCcAddr).val(ccAddresses);
  $(emailBccAddr).val(bccAddresses);
  $(emailReplyTo).val(replyTo);
  $(emailTemplateName).val(templateName);
  return $(emailTemplateData).val(templateData);
};

const switch_template = function (event) {
  const { value } = event.target;
  if (value === 'Preferences_template') {
    return $(txtTemplateData).val(sampleTemplateData);
  }
};

const validateTemplateData = function (event) {
  const { value } = event.target;
  if (value === "") {
    return console.log("Template data can't be empty");
  }
};

const loadSampleToAddress = function (event) {
  const { value } = event.target;
  if (value === "fake2@example.com") {
    $(emailToAddr).val("fake1@example.com");
    console.log("fake2@example.com is loaded");
    return console.log("fake1@example.com is populated");
  }
};

// switch DKIM type
const switch_dkim_type = function (event) {
  const { value } = event.target;
  if (value === 'byo_dkim') {
    $('#byo_dkim').removeClass('hide');
    return $('#easy_dkim').addClass('hide');
  } else if (value === 'easy_dkim') {
    $('#easy_dkim').removeClass('hide');
    return $('#byo_dkim').addClass('hide');
  }
};

// verify identity
const verify_identity = 'input[id="verified_email_identity"]';

const validate_identity = function (event) {
  const { value } = event.target;
  return console.log(`entered email address is : ${value}`);
};

$(document).on('modal:contentUpdated', function () {
  // email_source
  // handler to switch source type between email and domain
  $(document).on('change', 'select[data-toggle="sourceSwitch"]', switch_source_type);

  // plain_email
  $(document).on('change click', sourceDomainNamePart, update_name_part);
  $(document).on('change', 'select[data-toggle="sourceDomainSelect"]', switch_domain_name);

  // templated_email
  $(document).on('change', 'select[data-toggle="templateSwitch"]', switch_template);
  $(document).on('change', 'select[data-toggle="emailSelect"]', loadSampleToAddress);
  $(document).on('blur', 'textarea[id="templated_email_template_data"]', validateTemplateData);
  // verify identity
  $(document).on('change click', 'input[id="verified_email_identity"]', validate_identity);

  // create_email_identity_domain
  // handler to switch source type between email and domain
  return $(document).on('change', 'select[data-toggle="dkimTypeSwitch"]', switch_dkim_type);
});

$(function () {

  // settings
  const secret_key = $("div#settings-pane").find('table').children().find('tr').find('#td_secret_key');
  const secret_key_val = secret_key.html();
  const btn_tg_secret = $("div#settings-pane").find('table').children().find('tr').find("button#btn_tg_secret");
  const secret_key_x_val = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
  const eye = btn_tg_secret.find('#eye');
  const eye_slash = btn_tg_secret.find('#eye_slash');
  let isHidden = true;
  eye.show();
  eye_slash.hide();
  $(secret_key).html(secret_key_x_val);
  $(btn_tg_secret).on('click', () => {
    if (isHidden) {
      $(secret_key).html(secret_key_val);
      eye_slash.show();
      eye.hide();
      return isHidden = !isHidden;
    } else {
      $(secret_key).html(secret_key_x_val);
      eye.show();
      eye_slash.hide();
      return isHidden = !isHidden;
    }
  });

  // templates
  const template_name = "Preference_Template";
  const template_subject = "Preferences";
  const template_html_part = `\
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
</html>\
`;
  const template_text_part = `\
Your Preferences
Dear {{ name.lastName }},
You have indicated that you are interested in receiving information about the following topics:.
{{#each subscription}}
  {{interest}}
{{/each}}
You can change these settings at any time by visiting
the Preference Center https://www.abc.xyz/preferences/i.aspx?id={{meta.userId}}.\
`;

  const template_json_content = `\
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
}\
`;
  const templatesModal = 'body.templates.modal-open';
  const templateForm = 'form[id="form_template"]';
  const name = 'input[id="template_name"]';
  const subject = 'input[id="template_subject"]';
  const html_input = 'textarea[id="template_html_part"]';
  const text_input = 'textarea[id="template_text_part"]';
  const labelTemplateName = 'label[for="template_name"]';

  loadTestData = function () {
    $(name).val(template_name);
    $(subject).val(template_name);
    $(html_input).val(template_html_part);
    return $(text_input).val(template_text_part);
  };

  return $(templatesModal).on('click', () => $(labelTemplateName).on("click", () => loadTestData()));
});