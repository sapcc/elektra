import { createWidget } from 'widget';
import * as reducers from './reducers';
import App from './components/application';

createWidget(__dirname).then((widget) => {
  widget.configureAjaxHelper({
    baseURL: widget.config.scriptParams.limesApi,
    headers: {'X-Auth-Token': widget.config.scriptParams.token}
  })
  delete(widget.config.scriptParams.limesApi)
  delete(widget.config.scriptParams.token)
  widget.config.scriptParams.flavorData = JSON.parse(widget.config.scriptParams.flavorData)
  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
