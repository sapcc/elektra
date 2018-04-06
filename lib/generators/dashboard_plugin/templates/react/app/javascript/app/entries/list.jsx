import { Link } from 'react-router-dom';
import { TransitionGroup } from 'react-transition-group';
import { FadeTransition } from 'lib/components/transitions';
import { policy } from 'policy';
import SearchField from 'lib/components/search_field';
import EntryItem from './item';

export default class Entries extends React.Component {
  constructor(props){
  	super(props);
  	this.state = {};

    this.toolbar = this.toolbar.bind(this)
    this.renderTable = this.renderTable.bind(this)
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
    if(!props.active) return;
    props.loadEntriesOnce()
  }

  toolbar() {
    return (
      <div className='toolbar'>
        <TransitionGroup>
          { this.props.items.length>=4 &&
            <FadeTransition>
              <SearchField
                onChange={(term) => this.props.filterEntries(term)}
                placeholder='name or description'
                text='Searches by name or description in visible entries list only.
                      Entering a search term will automatically start loading the next pages
                      and filter the loaded items using the search term. Emptying the search
                      input field will show all currently loaded items.'/>
            </FadeTransition>
          }
        </TransitionGroup>

        { policy.isAllowed('cloud_ops:entry_create') &&
          <Link to='/entries/new' className='btn btn-primary'>Create new</Link>
        }
      </div>
    )
  }

  renderTable() {
    return (
      <table className='table entries'>
        <thead>
          <tr>
            <th>Name</th>
            <th>Description</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          { this.props.items && this.props.items.length>0 ? (
            this.props.items.map( (entry, index) =>
              !entry.isHidden &&
              <EntryItem
                key={index}
                entry={entry}
                handleDelete={this.props.handleDelete}/>
            )) : (
              <tr>
                <td colSpan="3">No Entries found.</td>
              </tr>
            )
          }
        </tbody>
      </table>
    )
  };

  render(){
    return (
      <div>
        { this.toolbar() }
        { !policy.isAllowed('cloud_ops:entry_list') ? (
          <span>You are not allowed to see this page</span>) : (
          this.props.isFetching ? <span className='spinner'></span> : this.renderTable()
        )}
      </div>
    )
  }
};
