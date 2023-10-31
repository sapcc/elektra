/*
 * decaffeinate suggestions:
 * DS102: Remove unnecessary code created because of implicit returns
 * Full docs: https://github.com/decaffeinate/decaffeinate/blob/master/docs/suggestions.md
 */

// PlainEmail
const plainEmailReplyToAddr = 'textarea[id="plain_email_reply_to_addr"]';
const plainEmailReturnPath = 'input[id="plain_email_return_path"]';
const sourceDomainNamePart = 'input[id="plain_email_source_domain_name_part"]';

// TemplatedEmail
const sourceDomainNamePartTemplated =
  'input[id="templated_email_source_domain_name_part"]';

// TemplatedEmail
const emailSource = 'select[id="templated_email_source"]';
const templatedEmailToAddr = 'textarea[id="templated_email_to_addr"]';
const templatedEmailCcAddr = 'input[id="templated_email_cc_addr"]';
const templatedEmailBccAddr = 'input[id="templated_email_bcc_addr"]';
const txtTemplateData = 'textarea[id="templated_email_template_data"]';
const templatedEmailReplyTo = 'textarea[id="templated_email_reply_to_addr"]';
const templatedEmailReturnPath = 'input[id="templated_email_return_path"]';

// Templates
const templateName = 'Preference_Template';
const templatesModal = 'body.templates.modal-open';
const name = 'input[id="template_name"]';
const subject = 'input[id="template_subject"]';
const html_input = 'textarea[id="template_html_part"]';
const text_input = 'textarea[id="template_text_part"]';
const labelTemplateName = 'label[for="template_name"]';
const templateHtmlPartSample = `\
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
const templateTextPartSample = `\
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

// Test data
const source = 'fake3@example.com';
const replyTo = 'fake3@example.com';
const toAddresses = 'fake1@example.com, fake2@example.com';
const ccAddresses = 'fake1@example.com, fake2@example.com';
const bccAddresses = 'fake1@example.com, fake2@example.com';
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

// email_source
const switch_source_type = function (event) {
  const { value } = event.target;
  /* Clear the ReplyTo and ReturnPath fields on PlainEmail Form */
  $(plainEmailReplyToAddr).val('');
  $(plainEmailReturnPath).val('');

  /* Clear the ReplyTo and ReturnPath fields on TemplatedEmail Form */
  $(templatedEmailReplyTo).val('');
  $(templatedEmailReturnPath).val('');

  if (value === 'email') {
    /* Hide the Domain Source if email Address is selected */
    $('#email-source').removeClass('hide');
    $('#domain-source').addClass('hide');
    $('#domain-source-name').addClass('hide');
  } else if (value === 'domain') {
    /* Hide the Email Source if Domain Address is selected */
    $('#domain-source').removeClass('hide');
    $('#domain-source-name').removeClass('hide');
    $('#email-source').addClass('hide');
  }
};

function hiliter(word, element) {
  var rgxp = new RegExp(word, 'g');
  var repl = '<span class="myClass">' + word + '</span>';
  element.innerHTML = element.innerHTML.replace(rgxp, repl);
}

const switch_domain_name = function (event) {
  let { value } = event.target;
  let domainPlaceholder = value === '' ? '' : `test@${value}`;
  $(sourceDomainNamePart).val(domainPlaceholder);
  $(sourceDomainNamePartTemplated).val(domainPlaceholder);
  hiliter('test', 'input[id="plain_email_source_domain_name_part"]');
  return value;
};
const update_name_part = function (event) {
  let { value } = event.target;
  return value;
};

const switch_template = function (event) {
  const { value } = event.target;
  if (value === 'Preferences_template') {
    return $(txtTemplateData).val(sampleTemplateData);
  }
};

const validateTemplateData = function (event) {
  const { value } = event.target;
  if (value === '') {
    return console.log("Template data can't be empty");
  }
};

const setReplyToAndReturnPath = function (event) {
  const { value } = event.target;

  /* Set ReplyTo and ReturnPath fields on PlainEmail Form */
  $(plainEmailReplyToAddr).val(value);
  $(plainEmailReturnPath).val(value);

  /* Set ReplyTo and ReturnPath fields on TemplatedEmail Form */
  $(templatedEmailReplyTo).val(value);
  $(templatedEmailReturnPath).val(value);
};

const setDomainReplyToAndReturnPath = function (event) {
  const { value } = event.target;

  /* Set ReplyTo and ReturnPath fields on TemplatedEmail Form */
  $(templatedEmailReplyTo).val(value);
  $(templatedEmailReturnPath).val(value);

  // /* Set ReplyTo and ReturnPath fields on PlainEmail Form */
  // $(plainEmailReplyToAddr).val(value);
  // $(plainEmailReturnPath).val(value);
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

const validateIdentity = function (event) {
  const { value } = event.target;
  return console.log(`entered email address is : ${value}`);
};

$(document).on('modal:contentUpdated', function () {
  // email_source
  // handler to switch source type between email and domain
  $(document).on(
    'change',
    'select[data-toggle="sourceSwitch"]',
    switch_source_type
  );

  // plain_email
  $(document).on('change click', sourceDomainNamePart, update_name_part);
  $(document).on(
    'change',
    'select[data-toggle="sourceDomainSelect"]',
    switch_domain_name
  );

  // TemplatedEmail
  $(document).on(
    'change',
    'select[data-toggle="templateSwitch"]',
    switch_template
  );

  // common to PlainEmail and TemplatedEmail
  $(document).on(
    'change',
    'select[data-toggle="emailSelect"]',
    setReplyToAndReturnPath
  );

  $(document).on('blur', sourceDomainNamePart, setDomainReplyToAndReturnPath);

  $(document).on(
    'blur',
    sourceDomainNamePartTemplated,
    setDomainReplyToAndReturnPath
  );

  $(document).on('blur', txtTemplateData, validateTemplateData);

  // verify identity
  $(document).on(
    'change click',
    'input[id="verified_email_identity"]',
    validateIdentity
  );

  // handler to switch source type between email and domain
  return $(document).on(
    'change',
    'select[data-toggle="dkimTypeSwitch"]',
    switch_dkim_type
  );
});

$(function () {
  // settings
  const secret_key = $('div#settings-pane')
    .find('table')
    .children()
    .find('tr')
    .find('#td_secret_key');
  const secret_key_val = secret_key.html();
  const btn_tg_secret = $('div#settings-pane')
    .find('table')
    .children()
    .find('tr')
    .find('button#btn_tg_secret');
  const secret_key_x_val = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx';
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
      return (isHidden = !isHidden);
    } else {
      $(secret_key).html(secret_key_x_val);
      eye.show();
      eye_slash.hide();
      return (isHidden = !isHidden);
    }
  });

  loadTestData = function () {
    $(name).val(templateName);
    $(subject).val(templateName);
    $(html_input).val(templateHtmlPartSample);
    return $(text_input).val(templateTextPartSample);
  };

  return $(templatesModal).on('click', () =>
    $(labelTemplateName).on('click', () => loadTestData())
  );
});
