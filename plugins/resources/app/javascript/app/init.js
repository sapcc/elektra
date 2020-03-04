import { createWidget } from 'widget';
import { configureCastellumAjaxHelper } from './actions/castellum';
import * as reducers from './reducers';
import MainApp from './components/applications/main';
import InitProjectApp from './components/applications/init_project';

createWidget(__dirname).then((widget) => {
  const limesHeaders = { 'X-Auth-Token': widget.config.scriptParams.token }
  if (widget.config.scriptParams.clusterId != 'current') {
    limesHeaders['X-Limes-Cluster-Id'] = widget.config.scriptParams.clusterId
  }
  widget.configureAjaxHelper({
    baseURL: widget.config.scriptParams.limesApi,
    headers: limesHeaders,
  })

  if (widget.config.scriptParams.castellumApi) {
    const castellumHeaders = {
      'X-Auth-Token': widget.config.scriptParams.token,
    };
    configureCastellumAjaxHelper({
      baseURL: widget.config.scriptParams.castellumApi,
      headers: castellumHeaders,
    });
    widget.config.scriptParams.hasCastellum = true;
  } else {
    widget.config.scriptParams.hasCastellum = false;
  }

  // cleanup 
  delete(widget.config.scriptParams.limesApi)
  delete(widget.config.scriptParams.castellumApi)
  delete(widget.config.scriptParams.token)

  //the script parameter "app" decides which entrypoint we're going to use
  let app = MainApp;
  switch (widget.config.scriptParams.app) {
    case "main":
      app = MainApp;
      break;
    case "init_project":
      app = InitProjectApp;
      break;
  }
  delete(widget.config.scriptParams.app)

  //convert params from strings into the respective types
  widget.config.scriptParams.flavorData = JSON.parse(widget.config.scriptParams.flavorData) 
  widget.config.scriptParams.bigVmResources = JSON.parse(widget.config.scriptParams.bigVmResources)
  widget.config.scriptParams.canEdit = widget.config.scriptParams.canEdit == 'true';
  widget.config.scriptParams.isForeignScope = widget.config.scriptParams.isForeignScope == 'true';

  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(app)
})
