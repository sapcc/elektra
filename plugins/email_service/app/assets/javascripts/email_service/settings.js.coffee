$(
  () ->
    secret_key = $("div#settings-pane").find('table').children().find('tr').find('#td_secret_key')
    secret_key_val = secret_key.html()
    btn_tg_secret = $("div#settings-pane").find('table').children().find('tr').find("button#btn_tg_secret")
    secret_key_x_val = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    eye = btn_tg_secret.find('#eye')
    eye_slash = btn_tg_secret.find('#eye_slash')
    isHidden = true
    eye.show()
    eye_slash.hide()
    $(secret_key).html(secret_key_x_val)
    $(btn_tg_secret).on('click', 
      () =>
        if isHidden
          $(secret_key).html(secret_key_val)
          eye_slash.show()
          eye.hide()
          isHidden = !isHidden
        else
          $(secret_key).html(secret_key_x_val)
          eye.show()
          eye_slash.hide()
          isHidden = !isHidden
    )
)