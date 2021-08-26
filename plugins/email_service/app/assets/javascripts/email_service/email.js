const toFakeAddresses = " rjones@sbcglobal.net, doormat@comcast.net, less mfburgo@me.com, alfred@outlook.com, mfleming@comcast.net, verymuch hermanab@comcast.net, dpitts@sbcglobal.net, care,fairbank@aol.com, moxfulder@live.com, tarreau@comcast.net, simone@sbcglobal.net, I,bahwi@outlook.com, jonas@optonline.net, so much malvar@verizon.net, zeller@yahoo.ca, policies@att.net, froodian@hotmail.com, alias@me.com, fmerges@att.net, tmccarth@yahoo.com";
const ccFakeAddresses = " curly@comcast.net, plover@me.com, jmcnamara@icloud.com, dgriffith@comcast.net, invalid,elmer@optonline.net, lamky@yahoo.ca, barlow@sbcglobal.net, random,timlinux@optonline.net, anicolao@me.com, jaesenj@yahoo.ca, some,cgcra@yahoo.com, guialbu@msn.com, benits@verizon.net, entries,bwcarty@icloud.com, pavel@msn.com, pplinux@mac.com, verizon,rmcfarla@mac.com, bjornk@verizon.net, globalcampbell@verizon.net, notaprguy@verizon.net";
const bccFakeAddresses = " greear@icloud.com, major,ranasta@gmail.com, forsberg@sbcglobal.net, pdbaby@verizon.net, afifi@aol.com, ninenine@verizon.net, potato mbswan@live.com, galbra@mac.com, vsprintf@hotmail.com, ducasse@att.net, tomato sopwith@yahoo.ca, wildfire@yahoo.ca, donev@mac.com, pdbaby@msn.com, gfody@hotmail.com, minor,frederic@hotmail.com, ardagna@optonline.net, citizenl@yahoo.com, makarow@gmail.com, xnormal@live.com";

const re = /[\s, ]+/; // comma and space regex.
const regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
// let toAddrProcessed, toAddrInput;
// let fixtoElementAdded = false;

let validToAddresses, validCcAddresses, validBccAddresses;
let validToAddressCount, validCcAddressCount, validBccAddressCount = 0;
let totalEmailAddresses = 0;

const errSpanEmailCount =  $("<span id=\"errEmailCount\"> eMail Count </span>");

$(document).ready(function() {

  // plain email form handling
  $('body.emails.modal-open').click(function(e) {
    target_id = e.target.id;
    initializeData();
    errSpanEmailCount.insertAfter(".flashes");
    errSpanEmailCount.hide();
    // if ( target_id === "email_subject" ) 
    //   loadFakeData();

    $("select#email_source").click(function() {
      var source_value = $('select#email_source').val();
      // console.log(`source_value : ${source_value}`);
    });

    $('textarea#email_to_addr').on ("blur click change", function() {
      validateEmails('#email_to_addr','span.toEmailHelpBlock','span.toEmailErrorBlock');
      getTotalEmailAddresses();
      $('span.toEmailErrorBlock').show();
      $('span.ccEmailErrorBlock').text("");
      $('span.bccEmailErrorBlock').text("");
      // console.log("blur or click event");
    });

    $('textarea#email_cc_addr').on ("blur click change", function() {
      validateEmails('#email_cc_addr','span.ccEmailHelpBlock','span.ccEmailErrorBlock');
      getTotalEmailAddresses();
      $('span.ccEmailErrorBlock').show();
      $('span.toEmailErrorBlock').text("");
      $('span.bccEmailErrorBlock').text("");
      // console.log("blur or click event");
    });

    $('textarea#email_bcc_addr').on ("blur click change", function() {
      validateEmails('#email_bcc_addr','span.bccEmailHelpBlock','span.bccEmailErrorBlock');
      getTotalEmailAddresses();
      $('span.bccEmailErrorBlock').show();
      $('span.toEmailErrorBlock').text("");
      $('span.ccEmailErrorBlock').text("");
      // console.log("blur or click event");
    });

  }); // body click ends

}); // document.ready ends

const initializeData = function(){
  // TODO REMOVE THIS
  // loadFakeData();
  validToAddressCount, validCcAddressCount, validBccAddressCount = 0;
  $('span.toEmailHelpBlock').css("color", "blue");
  $('span.ccEmailHelpBlock').css("color", "blue");
  $('span.bccEmailHelpBlock').css("color", "blue");

  $('span.toEmailErrorBlock').css("color", "red");
  $('span.ccEmailErrorBlock').css("color", "red");
  $('span.bccEmailErrorBlock').css("color", "red");
}

// TODO REMOVE THIS
const loadFakeData = function() {
  $("#email_to_addr").val(toFakeAddresses);
  $("#email_cc_addr").val(ccFakeAddresses);
  $("#email_bcc_addr").val(bccFakeAddresses);
}

const toggleCountError = function(totalCount) {
  errSpanEmailCount.show();
  errSpanEmailCount.css({ "color" : "red" , "font-size": "20" } );
  errSpanEmailCount.text(`emails count :${totalCount} is exceeding the allowed 50`);
}

const validateEmails = function (inputElement, helperBlock, errorBlock) {
  let result, invalidEntries, valideMailArr, helperText, errorText;
  valideMailArr = [];
  const inputText = $(inputElement).val();
  console.log(`totalEmailAddresses : ${totalEmailAddresses}`);
  if ( !inputText || inputText.length === 0 ){
      errorText = "At least one email address is required.";
      $(errorBlock).html(errorText);
  }
  else {
    result = processBulkEmail(inputText);
    invalidEntries = result.invalidEntries;
    valideMailArr = result.valideMailArr;
    console.log(`invalidEntries.length : ${invalidEntries.length}` );
    if (invalidEntries.length > 0) {
      errorText = `Invalid entries: <b><em> ${invalidEntries}</em></b> and will be omitted`;
      $(errorBlock).html(errorText);
    }
    if (valideMailArr.length <= 50) {
      helperText = `<b> ${valideMailArr.length} </b>valid email recipients of ${ (valideMailArr.length + invalidEntries.length) } entries.`;
      $(helperBlock).html(helperText);
    } else if (valideMailArr.length > 50) {
      errorText = `Error: Number of recipients <b> ${valideMailArr.length } </b> are exceeding the maximum limit of <b>50</b>`;
      $(errorBlock).html(errorText);
    }
  } 
  switch (inputElement) {
    case "#email_to_addr":
      validToAddresses = valideMailArr;
      validToAddressCount = valideMailArr.length;
    break;
    case "#email_cc_addr":
      validCcAddresses = valideMailArr;
      validCcAddressCount = valideMailArr.length;
    break;
    case "#email_bcc_addr":
      validBccAddresses = valideMailArr;
      validBccAddressCount = valideMailArr.length;

    break;
  }

  // return valideMailArr.length;
}

const processBulkEmail = function (inputText) {
  var invalidEntries = [];
  var valideMailArr = [];
  var emElement = "";
  emailList = inputText.split(re);
  // console.log("Unprocessed - Count is : " + emailList.length);
  emailList.forEach((element, index) => {
    emElement = element.trimEnd().trimStart();
    if (validateEmail(emElement)) {
      valideMailArr.push(emElement);
    }
    else {
      invalidEntries.push(element);
    }
  });
  // console.log("Processed - Count is : " + valideMailArr.length);
  // console.log("invalidEntries - Count is : " + invalidEntries.length);
  return { valideMailArr, invalidEntries };
}

const validateEmail = (email) => {
  return regex.test(String(email).toLowerCase());
}

const getTotalEmailAddresses = function() {
  console.log(`--TO: ${validToAddressCount}`);
  console.log(`--CC: ${validCcAddressCount}`);
  console.log(`--BCC: ${validBccAddressCount}`);
  totalEmailAddresses = validToAddressCount + validCcAddressCount + validBccAddressCount;
  if (totalEmailAddresses > 50 ) {
    toggleCountError(totalEmailAddresses);
  }
  console.log(`TOTAL: ${totalEmailAddresses}`);
  return totalEmailAddresses;
}


// console.log(window.pluginName);
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


  // $("#email_to_addr").on("blur", function () {
  //   toAddrInput = $("#email_to_addr").val();
  //   let valideMailArr, invalidEntries;
  //   result = processBulkEmail(toAddrInput);
  //   invalidEntries = result.invalidEntries;
  //   valideMailArr = result.valideMailArr;
  //   toAddrProcessed = valideMailArr;
  //   if (invalidEntries) {
  //     $("#email_to_addr").addClass("invalid");
  //     if (!fixtoElementAdded) {
  //       fixtoElementAdded = true;
  //     }
  //   } else {
  //     $("#email_to_addr").addClass("valid");
  //   }
  //   $(".toEmailHelpBlock").html(valideMailArr);
  //   $(".toErrBlock").html(invalidEntries.join(", "));

  // });

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
  //   validToAddresses = valideMailArr;
  //   validToAddressCount = valideMailArr.length;
  //   console.log(`To: ${validToAddressCount}`);
  // } else if (inputElement === "#email_cc_addr") {
  //   validCcAddresses = valideMailArr;
  //   validCcAddressCount = valideMailArr.length;
  //   console.log(`Cc: ${validCcAddressCount}`);
  // } else if (inputElement === "#email_bcc_addr") {
  //   validBccAddresses = valideMailArr;
  //   validBccAddressCount = valideMailArr.length;
  //   console.log(`Bcc: ${validBccAddressCount}`);
  // }




  // // Prefilling data
  // source_ids = ["email_to_addr", "email_cc_addr", "email_bcc_addr"];
  // if ( source_ids.some( id => target_id.includes(id) ) ) {
  //   initializeData();
  // }