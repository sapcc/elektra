import { SearchField } from 'lib/components/search_field';
import SearchItem from './search_item'
import { AjaxPaginate } from 'lib/components/ajax_paginate';

export default class Search extends React.Component {
  state = {
    domain: '',
    project: ''
  }

  delayedSearch = () => {
    if(this.timer) clearTimeout(this.timer)
    this.timer = setTimeout(() =>
      this.props.search({
        domain: this.state.domain, project: this.state.project
      })
    , 500)
  }

  search = (scope) => {
    this.setState(scope, this.delayedSearch)
  }

  render() {
    return (
      <React.Fragment>
        <div className="toolbar">
          <SearchField
            onChange={(domain) => this.search({domain})}
            placeholder='Domain name or ID'
            searchIcon={false}
          />
          &nbsp;/&nbsp;
          <SearchField
            onChange={(project) => this.search({project})}
            placeholder='Project name or ID'
            isFetching={this.props.projects.isFetching}
            searchIcon={true}
            text='Search Projects by domain and project name or id'
          />
          <span className="toolbar-input-divider"></span>
        </div>

        { this.props.projects.items && this.props.projects.items.length > 0 &&
          <table className="table">
            <thead>
              <tr>
                <th>Domain Name / ID</th>
                <th>Project Name / ID</th>
                <th className='snug'></th>
              </tr>
            </thead>
            <tbody>
              {
                this.props.projects.items.map((item,index) =>
                  <SearchItem
                    key={index}
                    item={item}
                    location={this.props.location}
                    domain={this.state.domain}
                    project={this.state.project}/>
                )
              }

            </tbody>
          </table>
        }

        <AjaxPaginate
          hasNext={this.props.projects.hasNext}
          isFetching={this.props.projects.isFetching}
          text={`${this.props.projects.items.length}/${this.props.projects.total}`}
          onLoadNext={() => this.props.loadNext({domain: this.state.domain, project: this.state.project})}/>
      </React.Fragment>
    )
  }
}
