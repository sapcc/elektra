// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `bin/rails generate channel` command.

import { createConsumer } from "@rails/actioncable"
;(function () {
  console.log("Cable init")
  window.App || (window.App = {})

  // do not create the consumer if user domain is unknown
  if (!window.scopedDomainFid) return null
  var path = "/" + window.scopedDomainFid
  if (window.scopedProjectId) path = path + "/" + window.scopedProjectId
  // create consumer
  window.App.cable = createConsumer(path + "/cable")
}.call(this))
