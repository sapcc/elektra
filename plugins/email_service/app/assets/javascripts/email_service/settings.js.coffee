$(
  () ->

  secret_toggle_button = $("#secret-toggle")

  shown_secret = $("div.settings-pane tr td").filter(".shown_secret")
  hidden_secret = $("div.settings-pane tr td").filter(".hidden_secret")
  secret_toggle_button = $("div.settings-pane tr td").filter("#secret_toggle")

    # console.log "Secret"
    # console.log shown_secret
    # console.log hidden_secret
    # console.log secret_toggle_button
    # console.log "Secret"
    # console.log "TOGGLE"
    # console.log $(secret_toggle_button)

  $(secret_toggle_button).on( "click", () ->
    console.log "Button clicked"
  );
);
