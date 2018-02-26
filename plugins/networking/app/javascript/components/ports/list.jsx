import { Link } from 'react-router-dom';
import { DefeatableLink } from 'lib/components/defeatable_link';
import { TransitionGroup, CSSTransition } from 'react-transition-group';
import SearchField from 'lib/components/search_field';
import PortItem from './item';
import AjaxPaginate from 'lib/components/ajax_paginate';

const TableRowFadeTransition = ({ children, ...props }) => (
  <CSSTransition {...props} timeout={200} classNames="css-transition-fade">
    {children}
  </CSSTransition>
);

export default class List extends React.Component {
  constructor(props) {
    super(props);
    this.filterPorts = this.filterPorts.bind(this)
  }

  componentWillReceiveProps(nextProps) {
    // load dependencies unless already loaded
    this.loadDependencies(nextProps)
  }

  componentDidMount() {
    // load dependencies unless already loaded
    this.loadDependencies(this.props)
  }

  loadDependencies(props) {
    props.loadPortsOnce()
  }

  filterPorts() {
    if(!this.props.searchTerm) return this.props.items;

    // filter items
    const regex = new RegExp(this.props.searchTerm.trim(), "i");
    return this.props.items.filter((i) =>
      `${i.id} ${i.ip} ${i.network} ${i.subnet} ${i.status}`.search(regex) >= 0
    )
  }

  toolbar() {
    if (!policy.isAllowed('networking:port_create')) return null;

    return (
      <div className='toolbar'>
        { this.props.items.length>0 &&
          <SearchField
            onChange={(term) => this.props.searchPorts(term)}
            placeholder='ID, IP or description'
            text='Searches by ID, IP or description in visible IP list only.
                  Entering a search term will automatically start loading the next pages
                  and filter the loaded items using the search term. Emptying the search
                  input field will show all currently loaded items.'/>
        }

        <DefeatableLink
          to='/ports/new'
          className='btn btn-primary'>
          Reserve new IP
        </DefeatableLink>
      </div>
    )
  }

  renderTable() {
    let items = this.filterPorts()

    return (
      <div>
        <table className='table shares'>
          <thead>
            <tr>
              <th>ID</th>
              <th>Network</th>
              <th>Subnet</th>
              <th>IP</th>
              <th>Status</th>
              <th></th>
            </tr>
          </thead>
          <TransitionGroup component="tbody">

              { items && items.length>0 ? (
                  items.map( (port, index) =>
                    !port.isHidden && <TableRowFadeTransition key={index}>
                        <PortItem
                          port={port}
                          handleDelete={this.props.handleDelete}/>
                      </TableRowFadeTransition>
                  )
                ) : (
                  <TableRowFadeTransition>
                    <tr>
                      <td colSpan="6">{ this.props.isFetching ? <span className='spinner'/> : 'No IPs found.' }</td>
                    </tr>
                  </TableRowFadeTransition>
                )
              }
          </TransitionGroup>
        </table>

        <AjaxPaginate
          hasNext={this.props.hasNext}
          isFetching={this.props.isFetching}
          onLoadNext={this.props.loadNext}/>
      </div>
    )
  }

  render() {
    return (
      <div>
        { this.toolbar() }
        { !policy.isAllowed('shared_filesystem_storage:share_list') ? (
            <span>You are not allowed to see this page</span>
          ) : (
            this.renderTable()
          )
        }
      </div>
    )
  }
}
