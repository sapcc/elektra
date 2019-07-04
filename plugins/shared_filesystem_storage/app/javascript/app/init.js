import { createWidget } from 'widget';
import { configureCastellumAjaxHelper } from './actions/castellum';
import * as reducers from './reducers';
import App from './components/application';

createWidget().then((widget) => {
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

  delete(widget.config.scriptParams.castellumApi)
  delete(widget.config.scriptParams.token)

  widget.configureAjaxHelper()
  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
