import { createWidget } from 'widget'
import * as reducers from './reducers';
import App from './application';

createWidget(__dirname, {html: {class: 'flex-body'}}).then((widget) => {
  widget.configureAjaxHelper()
  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
