import { AsyncTypeahead, Highlighter } from 'react-bootstrap-typeahead'
import { pluginAjaxHelper } from 'ajax_helper';

const ajaxHelper = pluginAjaxHelper('/')

export class AutocompleteField extends React.Component {
  state = {
    isLoading: false,
    options: [],
  }

  handleSearch = (searchTerm) => {
    let path
    switch(this.props.type) {
      case 'projects':
        path = 'projects'
        break;
      case 'users':
        path = 'users'
        break;
      case 'groups':
        path = 'groups'
        break;
    }

    const params = { term: searchTerm }
    if(this.props.domainId) params['domain'] = this.props.domainId

    this.setState({isLoading: true, options:[]})
    ajaxHelper.get(`/cache/${path}`, {params}).then( (response) => {
      if(response.data) {
        const options = response.data.map((i) => {
          return {
            name: i.name,
            id: i.uid || i.key || i.id,
            full_name: i.full_name || ''
          }
        })
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
    else if(this.props.type=='groups')
      placeholder = `Group ${placeholder}`
    return (
      <AsyncTypeahead
        isLoading={this.state.isLoading}
        options={this.state.options}
        autoFocus={true}
        emptyLabel={false}
        allowNew={false}
        multiple={false}
        onChange={this.props.onSelected}
        onInputChange={this.props.onInputChange}
        onSearch={this.handleSearch}
        labelKey="name"
        filterBy={['id', 'name', 'full_name']}
        placeholder={placeholder}
        renderMenuItemChildren={(option, props, index) =>{
          return [
            <Highlighter key="name" search={props.text}>
              {option.full_name ? `${option.full_name} (${option.name})` : option.name}
            </Highlighter>,
            <div className='info-text' key="id">
              <small>ID: {option.id}</small>
            </div>
          ]
        }
        }
      />
    )
  }
}
