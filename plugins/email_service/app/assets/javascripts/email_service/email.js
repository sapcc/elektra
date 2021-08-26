const toFakeAddresses = " rjones@sbcglobal.net, doormat@comcast.net, less mfburgo@me.com, alfred@outlook.com, mfleming@comcast.net, verymuch hermanab@comcast.net, dpitts@sbcglobal.net, care,fairbank@aol.com, moxfulder@live.com, tarreau@comcast.net, simone@sbcglobal.net, I,bahwi@outlook.com, jonas@optonline.net, so much malvar@verizon.net, zeller@yahoo.ca, policies@att.net, froodian@hotmail.com, alias@me.com, fmerges@att.net, tmccarth@yahoo.com";
const ccFakeAddresses = " curly@comcast.net, plover@me.com, jmcnamara@icloud.com, dgriffith@comcast.net, invalid,elmer@optonline.net, lamky@yahoo.ca, barlow@sbcglobal.net, random,timlinux@optonline.net, anicolao@me.com, jaesenj@yahoo.ca, some,cgcra@yahoo.com, guialbu@msn.com, benits@verizon.net, entries,bwcarty@icloud.com, pavel@msn.com, pplinux@mac.com, verizon,rmcfarla@mac.com, bjornk@verizon.net, globalcampbell@verizon.net, notaprguy@verizon.net";
const bccFakeAddresses = " greear@icloud.com, major,ranasta@gmail.com, forsberg@sbcglobal.net, pdbaby@verizon.net, afifi@aol.com, ninenine@verizon.net, potato mbswan@live.com, galbra@mac.com, vsprintf@hotmail.com, ducasse@att.net, tomato sopwith@yahoo.ca, wildfire@yahoo.ca, donev@mac.com, pdbaby@msn.com, gfody@hotmail.com, minor,frederic@hotmail.com, ardagna@optonline.net, citizenl@yahoo.com, makarow@gmail.com, xnormal@live.com";

const re = /[\s, ]+/; // comma and space regex.
const regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
// let toAddrProcessed, toAddrInput;
// let fixtoElementAdded = false;

let validToAddresses, validCcAddresses, validBccAddresses;
let validToAddressCount, validCcAddressCount, validBccAddressCount, totalEmailAddresses;

let toEmailHelpBlock, ccEmailHelpBlock, bccEmailHelpBlock;
let toEmailErrorBlock, ccEmailErrorBlock, bccEmailErrorBlock;
let emailSource, emailToAddr, emailCcAddr, emailBccAddr;

let errSpanEmailCount;
let err;

const initializeData = function(){

  toEmailHelpBlock = $("span.toEmailHelpBlock");
  ccEmailHelpBlock = $("span.ccEmailHelpBlock");
  bccEmailHelpBlock = $("span.bccEmailHelpBlock");

  toEmailErrorBlock = $("span.toEmailErrorBlock");
  ccEmailErrorBlock = $("span.ccEmailErrorBlock");
  bccEmailErrorBlock = $("span.bccEmailErrorBlock");

  emailSource  = 'select[id="email_source"]';
  emailToAddr  = 'textarea[id="email_to_addr"]'; 
  emailCcAddr  = 'textarea[id="email_cc_addr"]';
  emailBccAddr = 'textarea[id="email_bcc_addr"]';

  toEmailHelpBlock.css("color", "blue");
  ccEmailHelpBlock.css("color", "blue");
  bccEmailHelpBlock.css("color", "blue");

  toEmailErrorBlock.css("color", "red");
  ccEmailErrorBlock.css("color", "red");
  bccEmailErrorBlock.css("color", "red");
}

// TODO REMOVE THIS
const loadFakeData = function() {
  $(emailToAddr).val(toFakeAddresses);
  $(emailCcAddr).val(ccFakeAddresses);
  $(emailBccAddr).val(bccFakeAddresses);
}


$(document).ready(function() {
  // console.log(window.pluginName);
  validToAddressCount, validCcAddressCount, validBccAddressCount, totalEmailAddresses = 0;
  console.log("document is ready");
  
  // plain email form handling
  $('body.emails.modal-open').click(function(e) {
    target_id = e.target.id;
    initializeData();
    
    if ( target_id === "email_subject" ) {
      loadFakeData();
      toEmailErrorBlock.text("");
      ccEmailErrorBlock.text("");
      bccEmailErrorBlock.text("");
    }
      
    $(emailSource).click(function() {
      var source_value = $(this).val();
      console.log(`source_value : ${source_value}`);
    });

    if (totalEmailAddresses > 50)
      toggleCountError(totalEmailAddresses);

    $(emailToAddr).on ("blur click change", function(e) {
      validateEmails(emailToAddr, toEmailHelpBlock, toEmailErrorBlock);
      getTotalEmailAddresses();
      // toEmailErrorBlock.show();
      // ccEmailErrorBlock.text("");
      // bccEmailErrorBlock.text("");
      console.log("blur or click or change event");
      console.log(`event type : ${e.type}`);
    });

    $(emailCcAddr).on ("blur click change", function() {
      validateEmails(emailCcAddr, ccEmailHelpBlock, ccEmailErrorBlock);
      getTotalEmailAddresses();
      // ccEmailErrorBlock.show();
      // toEmailErrorBlock.text("");
      // bccEmailErrorBlock.text("");
      console.log("blur or click or change event");
    });

    $(emailBccAddr).on ("blur click change", function() {
      validateEmails(emailBccAddr, bccEmailHelpBlock, bccEmailErrorBlock);
      getTotalEmailAddresses();
      // bccEmailErrorBlock.show();
      // toEmailErrorBlock.text("");
      // ccEmailErrorBlock.text("");
      console.log("blur or click or change event");
    });

  }); // body click ends

}); // document.ready ends



const toggleCountError = function(totalCount) {
  $(errSpanEmailCount).insertAfter(".flashes");
  $(errSpanEmailCount).show();
  $(errSpanEmailCount).css({ "color" : "red" , "font-size": "20" } );
  $(errSpanEmailCount).text(`emails count :${totalCount} is exceeding the allowed 50`);
}

const validateEmails = function (inputElement, helperBlock, errorBlock) {
  let result, invalidEmailAddr, validEmailAddr, helperText, errorText, errors;
  validEmailAddr   = [];
  invalidEmailAddr = [];
  errors = [];
  console.log("INPUT ELEMENT: " + inputElement );
  const inputText = $(inputElement).val();

  if ( !inputText || inputText.length === 0 ){
      console.log( "Input Text is empty" );
      errorText = "At least one valid email address is required.";
      // $(errorBlock).html(errorText);
      $(helperBlock).html("");
      errors.push(errorText);
  }
  else {
    result = processBulkEmail(inputText);
    console.log (`RETURNED result : ${result}`);
    validEmailAddr = result.validEmails;
    invalidEmailAddr = result.invalidEmails;
    console.log(`validEmailAddr : ${validEmailAddr}`);
    console.log(`invalidEmailAddr : ${invalidEmailAddr}`);
    console.log(`invalidEmailAddr.length : ${invalidEmailAddr.length}` );
    if (invalidEmailAddr.length > 0) {
      errorText = `Invalid entries: <b><em> ${invalidEmailAddr}</em></b> and will be omitted`;
      // $(errorBlock).html(errorText);
      errors.push(errorText);
      console.log(errorText);
    }
    if (validEmailAddr.length <= 50) {
      helperText = `<b> ${validEmailAddr.length} </b>valid email recipients of ${ (validEmailAddr.length + invalidEmailAddr.length) } entries.`;
      $(helperBlock).html(helperText);
      console.log(helperText);
    } else if (validEmailAddr.length > 50) {
      errorText = `Number of recipients <b> ${validEmailAddr.length } </b> are exceeding the maximum limit of <b>50</b>`;
      // $(errorBlock).html(errorText);
      errors.push(errorText);
      console.log(errorText);
    }
  } 
  switch (inputElement) {
    case emailToAddr:
      validToAddresses = validEmailAddr;
      validToAddressCount = validEmailAddr.length;
      console.log(`switch: case : ${emailToAddr}`);
    break;
    case emailCcAddr:
      validCcAddresses = validEmailAddr;
      validCcAddressCount = validEmailAddr.length;
      console.log(`switch: case : ${emailCcAddr}`);
    break;
    case emailBccAddr:
      validBccAddresses = validEmailAddr;
      validBccAddressCount = validEmailAddr.length;
      console.log(`switch: case : ${emailBccAddr}`);
    break;
  }
  if (errors.length > 0 )
    handleError(errors, errorBlock);
  // return validEmails.length;
}

const processBulkEmail = function (inputText) {
  let validEmails, invalidEmails, emElement;
  validEmails  = [];
  invalidEmails = [];
  // emElement = "";
  emailList = inputText.split(re);
  emailList.forEach((emailItem, index) => {
    emElement = emailItem.trimEnd().trimStart();
    if ( regex.test(String(emElement).toLowerCase()) )
      validEmails.push(emElement);
    else
      invalidEmails.push(emailItem);
  });
  return { validEmails, invalidEmails };
}

const getTotalEmailAddresses = function() {
  totalEmailAddresses = validToAddressCount + validCcAddressCount + validBccAddressCount;
  if (totalEmailAddresses > 50 ) {
    toggleCountError(totalEmailAddresses);
  }
  return totalEmailAddresses;
}


const handleError = function(errors, element) {
  let errTxt;
  for ( var i = 0 ; i < errors.length; i++ ) {
    if ( typeof errTxt === "undefined" )
      errTxt = errors[i];
    else
      errTxt += `<br>${errors[i]}`;
  }
  $(element).html(errTxt);
}

// $('body.emails').css({backgroundColor: "#bbb"});

// $("#mainModal").on('shown.bs.modal', function () {
//   alert('The mainModal is fully shown.');
// });


// const afterPageLoad = function() {
//   console.log('this happens onLoad - Plain JavaScript');
// }
// window.onload = afterPageLoad; // works


// const email_source = document.querySelector('#email_source');
// const email_to_add = document.querySelector("#email_to_add");
// console.log(email_to_add);
// email_to_add.addEventListener('blur', function() {
//   console.log('email_source change event');
// });

  // Validate eMail Addresses from to, cc and bcc field and ensure count does not exceed 50.
  // emailValidate("#email_to_addr", "#toEmailHelpBlock", "#toErrBlock");
  // emailValidate("#email_cc_addr", "#ccEmailHelpBlock", "#ccErrBlock");
  // emailValidate("#email_bcc_addr", "#bccEmailHelpBlock", "#bccErrBlock");

  //   // document.getElementsByClassName("email-addr")[0];
  //   // $(".email-addr").forEach( (item, index ) => {
  //   //   emailValidate(".email-addr", "#toEmailHelpBlock", "#toErrBlock");
  //   // }


  // $('.modal').on('focus', function() {
  //   console.log("mainModel loaded");
  // });

  // console.log('doc is ready');
  // if ($('body').hasClass('modal-open')) {
  //   console.log('modal-open class is added');
  //   console.log($('#modal-dialog').find('.modal').is(":visible"));
  // }
 
  // if ( $('.modal').is(":visible") ) {
  //   console.log('modal is visble');
  //   // $("div.form-group.email_to_addr_fix").hide(); // addClass("hidden");
  //   // $("div.form-group.email_cc_addr_fix").hide(); // .addClass("hidden");
  //   // $("div.form-group.email_bcc_addr_fix").hide(); // .addClass("hidden");
  // }


  // if (inputElement === "#email_to_addr") {
  //   validToAddresses = validEmails;
  //   validToAddressCount = validEmails.length;
  //   console.log(`To: ${validToAddressCount}`);
  // } else if (inputElement === "#email_cc_addr") {
  //   validCcAddresses = validEmails;
  //   validCcAddressCount = validEmails.length;
  //   console.log(`Cc: ${validCcAddressCount}`);
  // } else if (inputElement === "#email_bcc_addr") {
  //   validBccAddresses = validEmails;
  //   validBccAddressCount = validEmails.length;
  //   console.log(`Bcc: ${validBccAddressCount}`);
  // }




  // // Prefilling data
  // source_ids = ["email_to_addr", "email_cc_addr", "email_bcc_addr"];
  // if ( source_ids.some( id => target_id.includes(id) ) ) {
  //   initializeData();
  // }