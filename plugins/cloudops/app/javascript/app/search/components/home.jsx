import { Link } from 'react-router-dom'
import { SearchField } from 'lib/components/search_field';
import SearchItem from './search_item'
// import { AjaxPaginate } from 'lib/components/ajax_paginate';
import { Pagination } from 'lib/components/pagination';

export default class Search extends React.Component {
  componentDidMount() {
    this.props.loadTypesOnce()
  }

  highlightSearchTerm = (string) => {
    if(!string) return
    const searchTerm = this.props.objects.searchTerm
    const searchType = this.props.objects.searchType

    if(!searchTerm || searchTerm.length==0) return string

    const index = string.indexOf(searchTerm)

    if(index<0) return string
    const length = searchTerm.length

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

        <div className="toolbar">
          { this.props.types.isFetching ?
            <span>
              <i className="spinner"></i>
              Loading Types...
            </span>
          :
            <select
              onChange={(e) => this.props.search({objectType: e.target.value})}
              value={this.props.objects.objectType}
            >
              <option value="">All</option>
              { availableTypes.map((type,index) =>
                <option value={type} key={index}>{type}</option>
              )}
            </select>
          }
          <span className="toolbar-input-divider"></span>
          <SearchField
            isFetching={this.props.objects.isFetching}
            onChange={(term) => this.props.search({term})}
            value={this.props.objects.searchTerm}
            placeholder='Object ID, name or description'
            text='Searches by ID, name or description.'
          />
          {this.props.objects.total > 0 &&
            <React.Fragment>
              <span className="toolbar-input-divider"></span>
              total: {this.props.objects.total}
            </React.Fragment>
          }
        </div>
        { this.props.objects.items && this.props.objects.items.length > 0 &&
          <table className="table">
            <thead>
              <tr>
                <th>Type</th>
                <th>Name/ID</th>
                <th className="search-result-details">Details</th>
                <th>Domain</th>
                <th>(Parent) Project</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {
                this.props.objects.items.map((item,index) =>
                  <SearchItem term={this.props.objects.searchTerm} item={item} key={index}/>
                )
              }

            </tbody>
          </table>
        }



        <div className="u-flex-container pagination-container">
          { this.props.objects.receivedAt &&
            // show this only after we have searched at least once (don't want this to be visible on initial load)
            <Link to='/universal-search/live'>
              Couldn't find what you were looking for?
            </Link>
          }
          <Pagination
            currentPage={this.props.objects.currentPage}
            total={this.props.objects.total}
            perPage={30}
            onChange={this.props.loadPage}
            className="pagination-container u-flex-pos-right"
          />
        </div>

      {/*
        <AjaxPaginate
          hasNext={this.props.objects.hasNext}
          isFetching={this.props.objects.isFetching}
          text={`${this.props.objects.items.length}/${this.props.objects.total}`}
          onLoadNext={this.props.loadNext}/>
      */}
      </React.Fragment>
    )
  }
}
