import { createWidget } from 'widget'
import * as reducers from './reducers';
import App from './application';

createWidget(__dirname, {html: {class: 'flex-body'}}).then((widget) => {
  widget.configureAjaxHelper(
    {
      baseURL: widget.config.scriptParams.url
    }
  )
  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
