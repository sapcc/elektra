import { createWidget } from 'widget';
import { configureCastellumAjaxHelper } from './actions/castellum';
import { configureMaiaAjaxHelper } from './actions/maia';
import * as reducers from './reducers';
import App from './components/application';

createWidget().then((widget) => {
  const apiHeaders = {
    'X-Auth-Token': widget.config.scriptParams.token,
  };

  if (widget.config.scriptParams.castellumApi) {
    configureCastellumAjaxHelper({
      baseURL: widget.config.scriptParams.castellumApi,
      headers: apiHeaders,
    });
    widget.config.scriptParams.hasCastellum = true;
  } else {
    widget.config.scriptParams.hasCastellum = false;
  }

  if (widget.config.scriptParams.maiaApi) {
    configureMaiaAjaxHelper({
      baseURL: widget.config.scriptParams.maiaApi,
      headers: apiHeaders,
    });
    widget.config.scriptParams.hasMaia = true;
  } else {
    widget.config.scriptParams.hasMaia = false;
  }

  delete(widget.config.scriptParams.castellumApi)
  delete(widget.config.scriptParams.maiaApi)
  delete(widget.config.scriptParams.token)

  widget.configureAjaxHelper()
  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
