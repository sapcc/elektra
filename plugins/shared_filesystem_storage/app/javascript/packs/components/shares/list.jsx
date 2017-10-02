import { withRouter } from 'react-router-dom'

import NewShare from './new'

const List = React.createClass({
  getInitialState() {
    return { showNew: false };
  },

  componentDidMount() {
    if(this.props.location.pathname == '/shares/new') {
      this.setState({ showNew: true })
    }
    this.loadDependencies()
  },

  loadDependencies() {
    this.props.loadSharesOnce()
    this.props.loadShareNetworksOnce()
    this.props.loadAvailabilityZonesOnce()
    for(let share of this.props.items){
      this.props.loadShareRulesOnce(share.id)
    }
  },

  closeNew() {
    this.setState({ showNew: false })
    this.props.history.replace('/shares')
  },
  openNew() {
    this.setState({ showNew: true })
    this.props.history.replace('/shares/new')
  },

  render() {
    return (
      <div>
        { true &&
          <div className='toolbar'>
            <button type="button" className="btn btn-primary" onClick={ (e) => this.openNew() }>
              Create new
            </button>
            <NewShare show={this.state.showNew} onHide={this.closeNew} />
          </div>
        }

        { this.props.isFetching ? (
          <span className='spinner'></span>
        ) : (
          <table className='table shares'>
            <thead>
              <tr>
                <th>Name</th>
                <th>
                  AZ
                  <i className='fa fa-fw fa-info-circle'
                    data-toggle="tooltip"
                    data-placement="top"
                    title="Availability Zone"></i>
                </th>
                <th>Protocol</th>
                <th>Size</th>
                <th>Status</th>
                <th>Network</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              { this.props.items.length>0 ? (
                this.props.items.map( (share, index) =>
                  <tr key={index}>
                    <td>{share.name}</td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                    <td></td>
                  </tr>
                )
              ) : (
                <tr>
                  <td colSpan="6">No Shares found.</td>
                </tr>
              )}
            </tbody>
          </table>

        )}


      </div>
    )
  }
});

export default withRouter(List);
