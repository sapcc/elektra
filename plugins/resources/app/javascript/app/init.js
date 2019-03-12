import { createWidget } from 'widget';
import * as reducers from './reducers';
import App from './components/application';

createWidget(__dirname).then((widget) => {
  const limesHeaders = { 'X-Auth-Token': widget.config.scriptParams.token }
  if (widget.config.scriptParams.clusterId != 'current') {
    limesHeaders['X-Limes-Cluster-Id'] = widget.config.scriptParams.clusterId
  }
  widget.configureAjaxHelper({
    baseURL: widget.config.scriptParams.limesApi,
    headers: limesHeaders,
  })

  delete(widget.config.scriptParams.limesApi)
  delete(widget.config.scriptParams.token)

  widget.config.scriptParams.flavorData = JSON.parse(widget.config.scriptParams.flavorData)
  widget.config.scriptParams.canEdit = widget.config.scriptParams.canEdit == 'true';
  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
