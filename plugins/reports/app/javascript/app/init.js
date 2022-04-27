import { createWidget } from 'widget'
import * as reducers from './reducers';
import App from './containers/app';

createWidget(__dirname).then((widget) => {
  // console.log('widget.config', widget.config)
  // console.log('widget.config.scriptParams.url',widget.config.scriptParams.url)

  let ajaxHelperOptions = {}
  if(widget.config.scriptParams.url) {
    ajaxHelperOptions['baseURL'] = widget.config.scriptParams.url
  }
  widget.configureAjaxHelper(ajaxHelperOptions)
  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})
