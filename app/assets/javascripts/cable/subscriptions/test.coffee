console.log("TEST")

App.cable.subscriptions.create { channel: 'TestChannel', room: '2' },
  received: (data) ->
    console.log("WebSocket message", data)
