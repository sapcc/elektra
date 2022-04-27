import { createWidget } from 'widget'
import * as reducers from './reducers';
import App from './components/application';

createWidget(__dirname).then((widget) => {
  widget.configureAjaxHelper(
    {
      baseURL: widget.config.scriptParams.url
    }
  )
  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
