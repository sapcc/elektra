import { createWidget } from 'widget'
import * as reducers from './reducers';
import App from './components/application';

createWidget().then((widget) => {
  widget.configureAjaxHelper()
  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
