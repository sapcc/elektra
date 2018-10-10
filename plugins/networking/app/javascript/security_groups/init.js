import { createWidget } from 'widget'
import * as reducers from './reducers';
import App from './components/application';
import Title from './components/title'

createWidget().then((widget) => {
  widget.configureAjaxHelper(
    {
      headers: {'X-Requested-With': 'XMLHttpRequest'}
    }
  )
  widget.setPolicy()
  widget.createStore(reducers)
  widget.render(App)
})

let title = document.getElementsByClassName('page-title');

// const ShowTheLocationWithRouter = withRouter(ShowTheLocation);
if(title && title.length>0) ReactDOM.render(<Title/>,title[0])
