import { createWidget } from "lib/widget"
import { configureCastellumAjaxHelper } from "./actions/castellum"
import * as reducers from "./reducers"
import MainApp from "./components/applications/main"
import InitProjectApp from "./components/applications/init_project"

createWidget(null).then((widget) => {
  const limesHeaders = { "X-Auth-Token": widget.config.scriptParams.token }
  widget.configureAjaxHelper({
    baseURL: widget.config.scriptParams.limesApi,
    headers: limesHeaders,
  })

  if (widget.config.scriptParams.castellumApi) {
    const castellumHeaders = {
      "X-Auth-Token": widget.config.scriptParams.token,
    }
    configureCastellumAjaxHelper({
      baseURL: widget.config.scriptParams.castellumApi,
      headers: castellumHeaders,
    })
    widget.config.scriptParams.hasCastellum = true
  } else {
    widget.config.scriptParams.hasCastellum = false
  }

  // cleanup
  delete widget.config.scriptParams.limesApi
  delete widget.config.scriptParams.castellumApi
  delete widget.config.scriptParams.token

  //the script parameter "app" decides which entrypoint we're going to use
  let app = MainApp
  switch (widget.config.scriptParams.app) {
    case "main":
      app = MainApp
      break
    case "init_project":
      app = InitProjectApp
      break
  }
  delete widget.config.scriptParams.app

  //console.log(widget.config.scriptParams)
  // convert params from strings into the respective types that you can access the data from props
  // check js_data in application_controller.rb
  widget.config.scriptParams.flavorData = JSON.parse(
    widget.config.scriptParams.flavorData
  )
  widget.config.scriptParams.projectShards = JSON.parse(
    widget.config.scriptParams.projectShards
  )
  widget.config.scriptParams.shardingEnabled = JSON.parse(
    widget.config.scriptParams.shardingEnabled
  )
  widget.config.scriptParams.projectScope = JSON.parse(
    widget.config.scriptParams.projectScope
  )

  widget.config.scriptParams.canEdit =
    widget.config.scriptParams.canEdit == "true"
  widget.config.scriptParams.canGotoCluster =
    widget.config.scriptParams.canGotoCluster == "true"
  widget.config.scriptParams.isForeignScope =
    widget.config.scriptParams.isForeignScope == "true"

  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(app)
})
