import { AsyncTypeahead, Highlighter } from 'react-bootstrap-typeahead'
import { ajaxHelper } from 'ajax_helper';

export class AutocompleteField extends React.Component {
  state = {
    isLoading: false,
    options: [],
  }

  handleSearch = (searchTerm) => {
    const match = window.location.href.match(/.+\/\/[^\/]+\/[^\/]+/)
    let url = match[0]
    if(this.props.type=='projects')
      url = `${url}/find_cached_projects`
    else if (this.props.type=='users')
      url = `${url}/find_users_by_name`

    this.setState({isLoading: true, options:[]})
    ajaxHelper.get(url, {params: { term: searchTerm } }).then( (response) => {
      if(response.data) {
        const options = response.data.map((i) =>
          ({name: i.full_name || i.name, id: i.key || i.id})
        )
        this.setState({isLoading: false, options: options})
      }
    })
    .catch( (error) => {});
  }

  render() {
    let placeholder = 'name or ID'
    if(this.props.type=='projects')
      placeholder = `Project ${placeholder}`
    else if(this.props.type=='users')
      placeholder = `User ${placeholder}`

    return (
      <AsyncTypeahead
        isLoading={this.state.isLoading}
        options={this.state.options}
        allowNew={false}
        multiple={false}
        onChange={this.props.onSelected}
        onSearch={this.handleSearch}
        labelKey="name"
        placeholder={placeholder}
        renderMenuItemChildren={(option, props, index) =>
          [
            <Highlighter key="name" search={props.text}>
              {option.name}
            </Highlighter>,
            <div className='info-text' key="id">
              <small>ID: {option.id}</small>
            </div>
          ]
        }
      />
    )
  }
}
