$ ->
  wishPlaceholders = [ "showed more detail", "would be less technical", "contained more docs" ]
  currentPlaceholder = wishPlaceholders[Math.floor(Math.random()*wishPlaceholders.length)]
  $("#wish-value").attr("placeholder", currentPlaceholder)

  $("#wish-value").focus ()->
    $(this).keypress (e)->
      if e.which == 13
        if $("#wish-value").val() != ""
          wishValue = $("#wish-text").text() + " " + $("#wish-value").val()
          Raven.captureMessage(wishValue, {level: "info"})
          $("#wish-value").hide()
          $("#wish-text").text("Thanks! We're on it.")
          event.preventDefault()
