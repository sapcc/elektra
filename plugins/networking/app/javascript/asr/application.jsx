import Router from './components/router'
import Config from './components/config'
import Statistics from './components/statistics'

import { fetchRouter, fetchConfig, fetchStatistics, syncRouter } from './actions'

const components = {
  'router': {component: Router, fetchFunc: fetchRouter},
  'config': {component: Config, fetchFunc: fetchConfig},
  'statistics': {component: Statistics, fetchFunc: fetchStatistics}
}

export default class Asr extends React.Component {
  state = {
    active: null,
    router: {isFetching: false, data: null, error: null},
    config: {isFetching: false, data: null, error: null},
    statistics: {isFetching: false, data: null, error: null}
  }

  componentDidMount(){
    this.select('router')
  }

  select = (component) => {
    if(!this.state[component] || !this.state[component].data) {
      this.loadData(component)
    }
    this.setState({active: component})
  }

  loadData = (component) => {
    const fetchFunc = components[component].fetchFunc

    this.setState({[component]: {...this.state[component], isFetching: true}}, () =>
      fetchFunc(this.props.routerId).then((data) => {
        this.setState({
          [component]: {...this.state[component], isFetching: false, data}
        })
      }).catch((error) => {
        this.setState({
          [component]: {...this.state[component], isFetching: false, error}
        })
      })
    )
  }

  handleSyncRouter = () => {
    this.setState({router: {...this.state[router], isFetching: true} })
    syncRouter(this.props.routerId).then( () => {
      loadData('router')
    }).catch(error =>
      this.setState({router: {...this.state[router], isFetching: false, error} })
    )
  }

  render() {
    if(!this.state.active) return null
    const CurrentComponent = components[this.state.active].component
    const componentProps = {...this.state[this.state.active]}
    if(this.state.active=='router') {
      componentProps['handleSyncRouter'] = this.handleSyncRouter
    }
    componentProps['routerId'] = this.props.routerId

    return (
      <React.Fragment>
        <div className='row'>
          <div className='col-sm-2'>
            <ul className="nav nav-pills nav-stacked">
              {['router','config','statistics'].map((component,index) =>
                <li
                  key={index}
                  role="presentation"
                  className={component==this.state.active ? 'active' : ''}>
                  <a href='#' onClick={(e) => { e.preventDefault(); this.select(component) }}>
                    {component.charAt(0).toUpperCase() + component.slice(1)}
                  </a>
                </li>
              )}
            </ul>
          </div>
          <div className="col-sm-10">
            <div className='tab-pane fade in active'>
              <CurrentComponent {...componentProps}/>
            </div>
          </div>
        </div>
      </React.Fragment>
    )
  }
}
