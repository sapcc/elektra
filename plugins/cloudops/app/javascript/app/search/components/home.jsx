import { Link } from 'react-router-dom'
import { SearchField } from 'lib/components/search_field';
import { SearchHighlight } from 'lib/components/search_highlight'
import SearchItem from './search_item'
import { AjaxPaginate } from 'lib/components/ajax_paginate';

export default class Search extends React.Component {
  state = {
    term: '',
    objectType: ''
  }

  delayedSearch = () => {
    if(this.timer) clearTimeout(this.timer)
    this.timer = setTimeout(() =>
      this.props.search({
        term: this.state.term, objectType: this.state.objectType
      })
    , 500)
  }

  searchByTerm = (term) => {
    this.setState({term}, this.delayedSearch)
  }

  searchByType = (objectType) => {
    this.setState({objectType}, this.delayedSearch)
  }

  componentDidMount() {
    this.props.loadTypesOnce()
  }

  highlightSearchTerm = (string) => {
    if(!string) return
    if(!this.state.term || this.state.term.length==0) return string

    const index = string.indexOf(this.state.term)

    if(index<0) return string
    const length = this.state.term.length

    return (
      <React.Fragment>
        {string.substring(0, index) }
        <span className='highlight'>
          {string.substring(index,index+length)}
        </span>
        {string.substring(index + string.length)}
      </React.Fragment>
    )
  }

  render() {
    const availableTypes = this.props.types.items.sort()
    return (
      <React.Fragment>

        <Link to='/'>Menu</Link>

        <div className="toolbar">
          { this.props.types.isFetching ?
            <React.Fragment>
              <span className="spinner"></span> Loading types...
            </React.Fragment>
          :
            <select
              onChange={(e) => this.searchByType(e.target.value)}
              value={this.state.objectType}
            >
              <option value="">All</option>
              { availableTypes.map((type,index) =>
                <option value={type} key={index}>{type}</option>
              )}
            </select>
          }
          <span className="toolbar-input-divider"></span>
          <SearchField
            onChange={(term) => this.searchByTerm(term)}
            placeholder='Object ID, name or project ID'
            text='Searches by ID, IP, network, subnet or description in visible IP list only.
                  Entering a search term will automatically start loading the next pages
                  and filter the loaded items using the search term. Emptying the search
                  input field will show all currently loaded items.'
          />
        </div>
        {
          this.props.objects.isFetching &&
          <span className="spinner"></span>
        }
        { this.props.objects.items && this.props.objects.items.length > 0 &&
          <table className="table">
            <thead>
              <tr>
                <th>Type</th>
                <th>ID</th>
                <th>Name</th>
                <th>Project ID</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {
                this.props.objects.items.map((item,index) =>
                  <SearchItem term={this.state.term} item={item} key={index}/>
                )
              }

            </tbody>
          </table>
        }

        <AjaxPaginate
          hasNext={this.props.objects.hasNext}
          isFetching={this.props.objects.isFetching}
          text={`${this.props.objects.items.length}/${this.props.objects.total}`}
          onLoadNext={() => this.props.loadNext({term: this.state.term, objectType: this.state.objectType})}/>
      </React.Fragment>
    )
  }
}
