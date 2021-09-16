// // regular expression to separate the email addresses (comma and space)
// var re = /[\s, ]+/; 
// // regular expression for valid email address
// var regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

// let validToAddresses, validCcAddresses, validBccAddresses;
// let validToAddressCount, validCcAddressCount, validBccAddressCount, totalEmailAddresses;

// let source_help, to_help, cc_help, bcc_help;
// let subject_help, htmlbody_help, textbody_help;

// // form elements
// const emailSource  = 'select[id="email_source"]';
// const emailToAddr  = 'textarea[id="email_to_addr"]'; 
// const emailCcAddr  = 'textarea[id="email_cc_addr"]';
// const emailBccAddr = 'textarea[id="email_bcc_addr"]';
// const emailSubject  = 'input[id="email_subject"]';
// const emailHtmlBody = 'textarea[id="email_htmlbody"]';
// const emailTextBody = 'textarea[id="email_textbody"]';
// const plainEmailForm = 'form[id="form_plain_email"]';

// // icon_hint classes
// const fg_email_source = '.form-group.email_source';
// const fg_email_to_addr = '.form-group.email_to_addr';
// const fg_email_cc_addr = '.form-group.email_cc_addr';
// const fg_email_bcc_addr = '.form-group.email_bcc_addr';
// const fg_email_subject = '.form-group.email_subject';
// const fg_email_htmlbody = '.form-group.email_htmlbody';
// const fg_email_textbody = '.form-group.email_textbody';

// // Test data
// const subject = "Cronus eMail Service - from Elektra UI Plugin - #{Time.new}";
// const htmlBody = "<h1>Email Sent by Cronus </h1><p><h2>AWS SES Proxy Service</h2>";
// const textBody = "Email Sent by Cronus - AWS SES Proxy Service";
// const toFakeAddresses = " rjones@sbcglobal.net, doormat@comcast.net, less mfburgo@me.com, alfred@outlook.com, mfleming@comcast.net, verymuch hermanab@comcast.net, dpitts@sbcglobal.net, care,fairbank@aol.com, moxfulder@live.com, tarreau@comcast.net, simone@sbcglobal.net, I,bahwi@outlook.com, jonas@optonline.net, so much malvar@verizon.net, zeller@yahoo.ca, policies@att.net, froodian@hotmail.com, alias@me.com, fmerges@att.net, tmccarth@yahoo.com";
// const ccFakeAddresses = " curly@comcast.net, plover@me.com, jmcnamara@icloud.com, dgriffith@comcast.net, invalid,elmer@optonline.net, lamky@yahoo.ca, barlow@sbcglobal.net, random,timlinux@optonline.net, anicolao@me.com, jaesenj@yahoo.ca, some,cgcra@yahoo.com, guialbu@msn.com, benits@verizon.net, entries,bwcarty@icloud.com, pavel@msn.com, pplinux@mac.com, verizon,rmcfarla@mac.com, bjornk@verizon.net, globalcampbell@verizon.net, notaprguy@verizon.net";
// const bccFakeAddresses = " greear@icloud.com, major,ranasta@gmail.com, forsberg@sbcglobal.net, pdbaby@verizon.net, afifi@aol.com, ninenine@verizon.net, potato mbswan@live.com, galbra@mac.com, vsprintf@hotmail.com, ducasse@att.net, tomato sopwith@yahoo.ca, wildfire@yahoo.ca, donev@mac.com, pdbaby@msn.com, gfody@hotmail.com, minor,frederic@hotmail.com, ardagna@optonline.net, citizenl@yahoo.com, makarow@gmail.com, xnormal@live.com";

// const initializeData = function() {
//   source_help = $(".form-group.email_source p").filter(".help-block");
//   to_help = $(".form-group.email_to_addr p").filter(".help-block");
//   cc_help = $(".form-group.email_cc_addr p").filter(".help-block");
//   bcc_help = $(".form-group.email_bcc_addr p").filter(".help-block");
//   subject_help = $(".form-group.email_subject p").filter(".help-block");
//   htmlbody_help = $(".form-group.email_htmlbody p").filter(".help-block");
//   textbody_help = $(".form-group.email_textbody p").filter(".help-block");
// }


// $(document).ready( function() {

//   validToAddressCount, validCcAddressCount, validBccAddressCount, totalEmailAddresses = 0;

//   // plain email form handling
//   $('body.emails.modal-open').on( "mouseover", function() {
//     initializeData();
//     increaseTextArea();

    
//     // handle blur and change events on email source select input
//     $(emailSource).on("change blur", function() {
//       // loadFakeData();
//       var source_value = $(this).val();
//       if ( !source_value && source_value.length == 0 ) { // source_value === "undefined" || source_value === null  ) {
//         $(fg_email_source).addClass('has-error');
//         source_help.html(getHelpText("Source email can\'t be empty",""));
//         source_help.show();
//       } else {
//         source_help.html(getHelpText("","valid"));
//         $(fg_email_source).removeClass('has-error');
//         source_help.hide(500);
//       }
//     });

//     $(emailToAddr).on("blur click", function() {
//       validateEmails(emailToAddr);
//       $(this).addClass("u-text-monospace");
//       $(this).css("color", "blue");
//     });

//     $(emailCcAddr).on("blur click", function() {
//       validateEmails(emailCcAddr);
//       $(this).addClass("u-text-monospace");
//       $(this).css("color", "blue");
//     });

//     $(emailBccAddr).on("blur click", function() {
//       validateEmails(emailBccAddr);
//       $(this).addClass("u-text-monospace");
//       $(this).css("color", "blue");
//     });  

//     $(emailSubject).on("blur click", function() {
//       $(this).addClass("u-text-monospace");
//       $(this).css("color", "blue");
//       if ( $(this).val().length === 0 ) {
//         $(fg_email_subject).addClass('has-error');
//         $(subject_help).html( getHelpText("<b>Subject</b> can't be empty","") );
//         $(subject_help).show();
//       } else {
//         $(fg_email_subject).removeClass('has-error');
//         $(subject_help).html( getHelpText("","valid") );
//         $(subject_help).hide(500);
//       }
//     });
//     $(emailHtmlBody).on("blur click", function() {
//       $(this).addClass("u-text-monospace");
//       $(this).css("color", "blue");
//       if ( $(this).val().length === 0 ) {
//         $(fg_email_htmlbody).addClass('has-error');
//         $(htmlbody_help).html( getHelpText("<b>HTML Body</b> can't be empty","") );
//         $(htmlbody_help).show();
//       } else {
//         $(fg_email_htmlbody).removeClass('has-error');
//         $(htmlbody_help).html( getHelpText("","valid") );
//         $(htmlbody_help).hide(500);
//       }
//     });
//     $(emailTextBody).on("blur click", function() {
//       $(this).addClass("u-text-monospace");
//       $(this).css("color", "blue");
//       if ( $(this).val().length === 0 ) {
//         $(fg_email_textbody).addClass('has-error');
//         $(textbody_help).html( getHelpText("<b>Text Body</b> can't be empty","") );
//         $(textbody_help).show();
//       } else {
//         $(fg_email_textbody).removeClass('has-error');
//         $(textbody_help).html( getHelpText("","valid") );
//         $(textbody_help).hide(500);
//       }
//     });
    
//   }); // document body mouseover
// });// document ready

// const checkEmptyInput = function( inpText ) {
//   (!inpText || inpText.length === 0) ? true : false
// }

// const increaseTextArea = function() {
//   // increase the to, cc and bcc textarea row size depends on the input
//   if ( $(emailToAddr).val().length >= 30 ) 
//     $(emailToAddr).prop("rows", "10");
//   else
//     $(emailToAddr).prop("rows", "1");

//   if ( $(emailCcAddr).val().length >= 30 ) 
//     $(emailCcAddr).prop("rows", "10");
//   else
//     $(emailCcAddr).prop("rows", "1");

//   if ( $(emailBccAddr).val().length >= 30 ) 
//     $(emailBccAddr).prop("rows", "10");
//   else
//     $(emailBccAddr).prop("rows", "1");
// }

// // // TODO REMOVE THIS
// // const loadFakeData = function() {
// //   $(emailToAddr).val(toFakeAddresses);
// //   $(emailCcAddr).val(ccFakeAddresses);
// //   $(emailBccAddr).val(bccFakeAddresses);
// //   $(emailSubject).val(subject);
// //   $(emailHtmlBody).val(htmlBody);
// //   $(emailTextBody).val(textBody);
// // }


// const getHelpText = function (errText, helpText){
//   var errSpan = (errText) ? `<span class='helpSpan'>${errText}</span>` : "";;
//   var helpSpan = (helpText) ? `<span class='helpSpan'>${helpText}</span>` : "";
//   return `<i class='fa fa-info-circle'></i>${helpSpan} ${errSpan} `;
// }

// const validateEmails = function (inputElement) {
//   let result, invalidEmails, validEmails, helperText, errorText, emElement;
//   validEmails   = [];
//   invalidEmails = [];

//   const inputText = $(inputElement).val().trimEnd().trimStart();
//   $(inputElement).val(inputText);
//   if ( (!inputText || inputText.length === 0) && totalEmailAddresses === 0 ){
//       errorText = "At least one valid email address is required.";
//   } else {
//     inputText.split(re).forEach((emailItem, index) => {
//       emElement = emailItem.trimEnd().trimStart();
//       if ( regex.test(String(emElement).toLowerCase()) )
//         validEmails.push(emElement);
//       else
//         invalidEmails.push(emailItem);
//     });
//     if (invalidEmails.length > 0) 
//       errorText = `Invalid entries: <b><em> ${invalidEmails}</em></b>.`;
//     if (validEmails.length <= 50)
//       helperText = `<b> ${validEmails.length} </b>valid email recipients of ${ (validEmails.length + invalidEmails.length) } entries.`;
//   }
//   switch (inputElement) {
//     case emailToAddr:
//       validToAddresses = validEmails;
//       validToAddressCount = validEmails.length;
//       $(to_help).show();
//       if (invalidEmails.length > 0 || errorText ) {
//         $(to_help).html( getHelpText(errorText, helperText) );
//         $(fg_email_to_addr).addClass('has-error');
//       }
//       else {
//         $(to_help).html( getHelpText("", helperText) );
//         $(fg_email_to_addr).removeClass('has-error');
//       }
//       if ( validEmails.length > 0 && invalidEmails.length === 0 ) 
//         $(to_help).hide(1000);
//     break;
//     case emailCcAddr:
//       $(cc_help).show();
//       validCcAddresses = validEmails;
//       validCcAddressCount = validEmails.length;
//       if (invalidEmails.length > 0 || errorText ) {
//         $(cc_help).html( getHelpText(errorText, helperText) );
//         $(fg_email_cc_addr).addClass('has-error');
//       }else {
//         $(cc_help).html( getHelpText("", helperText) );
//         $(fg_email_cc_addr).removeClass('has-error');
//       }
//       if ( validEmails.length > 0 && invalidEmails.length === 0 ) 
//         $(cc_help).hide(1000);
//     break;
//     case emailBccAddr:
//       validBccAddresses = validEmails;
//       validBccAddressCount = validEmails.length;
//       $(bcc_help).show();
//       if (invalidEmails.length > 0 || errorText ){
//         $(bcc_help).html( getHelpText(errorText, helperText) );
//         $(fg_email_bcc_addr).addClass('has-error');
//       }else {
//         $(bcc_help).html( getHelpText("", helperText) );
//         $(fg_email_bcc_addr).removeClass('has-error');
//       }
//       if ( validEmails.length > 0 && invalidEmails.length === 0 ) 
//         $(bcc_help).hide(1000);
//     break;
//   }
//   getTotalEmailAddresses();
// }


// const getTotalEmailAddresses = function() {
//   totalEmailAddresses = validToAddressCount + validCcAddressCount + validBccAddressCount;
//   if (totalEmailAddresses > 50 )
//     errorText = `emails count :${totalEmailAddresses} is exceeding the allowed 50`;
// }
