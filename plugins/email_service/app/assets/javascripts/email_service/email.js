// const toFakeAddresses = " rjones@sbcglobal.net, doormat@comcast.net, less mfburgo@me.com, alfred@outlook.com, mfleming@comcast.net, verymuch hermanab@comcast.net, dpitts@sbcglobal.net, care,fairbank@aol.com, moxfulder@live.com, tarreau@comcast.net, simone@sbcglobal.net, I,bahwi@outlook.com, jonas@optonline.net, so much malvar@verizon.net, zeller@yahoo.ca, policies@att.net, froodian@hotmail.com, alias@me.com, fmerges@att.net, tmccarth@yahoo.com";
// const ccFakeAddresses = " curly@comcast.net, plover@me.com, jmcnamara@icloud.com, dgriffith@comcast.net, invalid,elmer@optonline.net, lamky@yahoo.ca, barlow@sbcglobal.net, random,timlinux@optonline.net, anicolao@me.com, jaesenj@yahoo.ca, some,cgcra@yahoo.com, guialbu@msn.com, benits@verizon.net, entries,bwcarty@icloud.com, pavel@msn.com, pplinux@mac.com, verizon,rmcfarla@mac.com, bjornk@verizon.net, globalcampbell@verizon.net, notaprguy@verizon.net";
// const bccFakeAddresses = " greear@icloud.com, major,ranasta@gmail.com, forsberg@sbcglobal.net, pdbaby@verizon.net, afifi@aol.com, ninenine@verizon.net, potato mbswan@live.com, galbra@mac.com, vsprintf@hotmail.com, ducasse@att.net, tomato sopwith@yahoo.ca, wildfire@yahoo.ca, donev@mac.com, pdbaby@msn.com, gfody@hotmail.com, minor,frederic@hotmail.com, ardagna@optonline.net, citizenl@yahoo.com, makarow@gmail.com, xnormal@live.com";

// const re = /[\s, ]+/; // comma and space regex.
// const regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

// let validToAddresses, validCcAddresses, validBccAddresses;
// let validToAddressCount, validCcAddressCount, validBccAddressCount, totalEmailAddresses;

// let toEmailHelpBlock, ccEmailHelpBlock, bccEmailHelpBlock;
// let toEmailErrorBlock, ccEmailErrorBlock, bccEmailErrorBlock;
// let emailSource, emailToAddr, emailCcAddr, emailBccAddr;

// let errSpanEmailCount;
// let err;

// let subject = "Cronus eMail Service - from Elektra UI Plugin - #{Time.new}";
// let htmlBody = "<h1>Email Sent by Cronus </h1><p><h2>AWS SES Proxy Service</h2>";
// let textBody = "Email Sent by Cronus - AWS SES Proxy Service";

// const initializeData = function(){

//   toEmailHelpBlock = $("span.toEmailHelpBlock");
//   ccEmailHelpBlock = $("span.ccEmailHelpBlock");
//   bccEmailHelpBlock = $("span.bccEmailHelpBlock");

//   toEmailErrorBlock = $("span.toEmailErrorBlock");
//   // toEmailErrorBlock = $("form-group.email_to_addr p").filter(".help-block");
//   ccEmailErrorBlock = $("span.ccEmailErrorBlock");
//   bccEmailErrorBlock = $("span.bccEmailErrorBlock");

//   emailSource  = 'select[id="email_source"]';
//   emailToAddr  = 'textarea[id="email_to_addr"]'; 
//   emailCcAddr  = 'textarea[id="email_cc_addr"]';
//   emailBccAddr = 'textarea[id="email_bcc_addr"]';
//   emailSubject  = 'input[id="email_subject"]';
//   emailHtmlBody = 'textarea[id="email_htmlbody"]';
//   emailTextBody = 'textarea[id="email_textbody"]';


//   toEmailHelpBlock.css("color", "blue");
//   ccEmailHelpBlock.css("color", "blue");
//   bccEmailHelpBlock.css("color", "blue");

//   toEmailErrorBlock.css("color", "red");
//   ccEmailErrorBlock.css("color", "red");
//   bccEmailErrorBlock.css("color", "red");
// }

// // TODO REMOVE THIS
// const loadFakeData = function() {
//   $(emailToAddr).val(toFakeAddresses);
//   $(emailCcAddr).val(ccFakeAddresses);
//   $(emailBccAddr).val(bccFakeAddresses);

//   $(emailSubject).val(subject);
//   $(emailHtmlBody).val(htmlBody);
//   $(emailTextBody).val(textBody);

//   toEmailErrorBlock.hide();
//   ccEmailErrorBlock.hide();
//   bccEmailErrorBlock.hide();
// }


// $(document).ready(function() {
//   // console.log(window.pluginName);
//   validToAddressCount, validCcAddressCount, validBccAddressCount, totalEmailAddresses = 0;
  
//   // plain email form handling
//   $('body.emails.modal-open').click(function(e) {
//     target_id = e.target.id;
//     initializeData();
      
//     $(emailSource).on("change", function() {
//       loadFakeData();
//       var source_value = $(this).val();
//       console.log(`source_value : ${source_value}`);
//     });


//     $(emailToAddr).on ("blur click", 
//       validateEmails(emailToAddr, toEmailHelpBlock, toEmailErrorBlock) );

//     $(emailCcAddr).on ("blur click", 
//       validateEmails(emailCcAddr, ccEmailHelpBlock, ccEmailErrorBlock));

//     $(emailBccAddr).on ("blur click",
//       validateEmails(emailBccAddr, bccEmailHelpBlock, bccEmailErrorBlock) );

//   }); // body click ends

// }); // document.ready ends



// const toggleCountError = function(totalCount) {
//   $(errSpanEmailCount).insertAfter(".flashes");
//   $(errSpanEmailCount).show();
//   $(errSpanEmailCount).css({ "color" : "red" , "font-size": "20" } );
//   $(errSpanEmailCount).text(`emails count :${totalCount} is exceeding the allowed 50`);
// }

// const validateEmails = function (inputElement, helperBlock, errorBlock) {
//   let result, invalidEmailAddr, validEmailAddr, helperText, errorText, errors;
//   validEmailAddr   = [];
//   invalidEmailAddr = [];
//   errors = [];
//   const inputText = $(inputElement).val().trimEnd().trimStart();

//   $(inputElement).val(inputText);

//   if ( (!inputText || inputText.length === 0) && totalEmailAddresses === 0 ){
//       errorText = "At least one valid email address is required.";
//       $(helperBlock).hide(); 
//       errors.push(errorText);
//   }
//   else {
//     result = processBulkEmail(inputText);
//     validEmailAddr = result.validEmails;
//     invalidEmailAddr = result.invalidEmails;
//     if (invalidEmailAddr.length > 0) {
//       errorText = `Invalid entries: <b><em> ${invalidEmailAddr}</em></b>.`;
//       errors.push(errorText);
//     }
//     if (validEmailAddr.length <= 50) {
//       helperText = `<b> ${validEmailAddr.length} </b>valid email recipients of ${ (validEmailAddr.length + invalidEmailAddr.length) } entries.`;
//       if ( invalidEmailAddr.length == 0 && validEmailAddr.length >= 1 ){
//         $(helperBlock).hide();
//         $(errorBlock).hide();
//       } else {
//         $(helperBlock).html(helperText);
//         $(errorBlock).show();
//       }  
//     } else if (validEmailAddr.length > 50) {
//       errorText = `Number of recipients <b> ${validEmailAddr.length } </b> are exceeding the maximum limit of <b>50</b>`;
//       $(errorBlock).show();
//       errors.push(errorText);
//     }
//   } 
//   switch (inputElement) {
//     case emailToAddr:
//       validToAddresses = validEmailAddr;
//       validToAddressCount = validEmailAddr.length;
//     break;
//     case emailCcAddr:
//       validCcAddresses = validEmailAddr;
//       validCcAddressCount = validEmailAddr.length;
//     break;
//     case emailBccAddr:
//       validBccAddresses = validEmailAddr;
//       validBccAddressCount = validEmailAddr.length;
//     break;
//   }
//   getTotalEmailAddresses();
//   if (errors.length > 0 )
//     handleError(errors, errorBlock);
//   // return validEmails.length;
// }

// const processBulkEmail = function (inputText) {
//   let validEmails, invalidEmails, emElement;
//   validEmails  = [];
//   invalidEmails = [];
//   emailList = inputText.split(re);
//   emailList.forEach((emailItem, index) => {
//     emElement = emailItem.trimEnd().trimStart();
//     if ( regex.test(String(emElement).toLowerCase()) )
//       validEmails.push(emElement);
//     else
//       invalidEmails.push(emailItem);
//   });
//   return { validEmails, invalidEmails };
// }

// const getTotalEmailAddresses = function() {
//   totalEmailAddresses = validToAddressCount + validCcAddressCount + validBccAddressCount;
//   if (totalEmailAddresses > 50 ) {
//     toggleCountError(totalEmailAddresses);
//   }
//   return totalEmailAddresses;
// }


// const handleError = function(errors, element) {
//   let errTxt;
//   for ( var i = 0 ; i < errors.length; i++ ) {
//     if ( typeof errTxt === "undefined" )
//       errTxt = errors[i];
//     else
//       errTxt += `<br>${errors[i]}`;
//   }
//   $(element).html(errTxt);
// }



// // const afterPageLoad = function() {
// //   console.log('this happens onLoad - Plain JavaScript');
// // }
// // window.onload = afterPageLoad; // works

// // // Prefilling data
// // source_ids = ["email_to_addr", "email_cc_addr", "email_bcc_addr"];
// // if ( source_ids.some( id => target_id.includes(id) ) ) {
// //   initializeData();
// // }