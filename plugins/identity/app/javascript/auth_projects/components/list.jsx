
export default class List extends React.Component {
  state = {
    hierarchicalProjects: [],
    expandedLists: {},
    showSearchInput: true,
    searchTerm: null
  }

  static defaultProps = {
    title: 'Your Projects',
    showCount: true
  }


  componentDidMount(){
    this.props.loadAuthProjectsOnce()

    const newState = {}
    if(this.props.showSearchInput==false) newState['showSearchInput'] = false
    if(this.props.items && this.props.items.length > 0) {
      newState['hierarchicalProjects'] = this.buildHierarchy(this.props.items)
    }
    this.setState(newState, () => {
      if(this.state.showSearchInput && this.searchInput) this.searchInput.focus()
    })
  }

  componentWillReceiveProps = (nextProps) => {
    if(nextProps.items && nextProps.items.length > 0) {
      this.setState({hierarchicalProjects: this.buildHierarchy(nextProps.items)})
    }
  }

  toggleSubtree = (itemId) => {
    const newExpandedList = {...this.state.expandedLists}
    newExpandedList[itemId] = !newExpandedList[itemId]
    this.setState({expandedLists: newExpandedList})
  }

  toggleSearchInput = (e) => {
    e.preventDefault()
    let show = !this.state.showSearchInput
    this.setState({showSearchInput: show}, () => {
      if(show && this.searchInput) this.searchInput.focus()
    })
  }

  updateSearchTerm = (e) => {
    this.setState({searchTerm: e.target.value})
  }

  buildHierarchy = (items) => {
    const map = {}
    for(let item of items) {
      map[item.id] = {
        name: item.name,
        parent_id: item.parent_id,
        domain_id: item.domain_id,
        id: item.id
      }
    }

    const root = []

    for(let id in map) {
      const item = map[id]
      let parent

      if(item.parent_id && item.parent_id != item.domain_id) {
        parent = map[item.parent_id]
      }

      if(parent) {
        parent.children = parent.children || []
        parent.children.push(item)
      } else {
        root.push(item)
      }
    }
    if (this.props.root && map[this.props.root])
      return map[this.props.root].children || []
    return root
  }

  renderHierarchy = (projects) => {
    const searchMode = this.state.searchTerm && this.state.searchTerm.length>0

    return projects.map((project,index) => {
      const hasChildren = project.children && project.children.length>0
      let children = null
      if(hasChildren) {
        children = this.renderHierarchy(project.children).filter(child => child != null)
      }

      let labelClass
      if(searchMode && project.name.indexOf(this.state.searchTerm)<0) {
        if(!hasChildren || children.length == 0) return null
        labelClass = 'info-text'
      }

      let className = ''
      if(hasChildren) className += ' has-children'
      if(this.state.expandedLists[project.id] || searchMode) className += ' node-expanded'

      return <li key={index} className={className}>
        <i className="node-icon" onClick={(e) => this.toggleSubtree(project.id)}></i>
        <a href={`/${project.domain_id}/${project.id}/home`} className={labelClass}>{project.name}</a>
        {hasChildren && children.length>0 && <ul>{children}</ul>}
      </li>
    })
  };

  render(){
    const searchEnabled = this.props.items && this.state.hierarchicalProjects.length > 9

    return (
      <React.Fragment>
        {this.props.title &&
          <h4 className="action-heading heading-top">
            {this.props.title}
            {this.props.showCount && this.props.items && this.props.items.length > 0 &&
              ` (${this.props.items.length})`
            }
            {searchEnabled &&
              <div className="header-action">
                <i className="fa fa-search" onClick={this.toggleSearchInput}></i>
              </div>
            }
          </h4>
        }

        {this.state.showSearchInput && searchEnabled &&
          <div className='toolbar-secondary'>
            <div className="has-feedback">
              <input
                type="text"
                name="search-input"
                id="search-input"
                ref={(input) => { this.searchInput = input }}
                onChange={this.updateSearchTerm}
                value={this.state.searchTerm || ''}
                className="form-control"
                placeholder="Search project name"/>

              {this.state.searchTerm && this.state.searchTerm.length>0 &&
                <span className="form-control-feedback not-empty">
                  <i className="fa fa-times-circle" onClick={() => this.setState({searchTerm: null}) }></i>
                </span>
              }
            </div>
          </div>
        }

        {this.props.isFetching ?
          <React.Fragment><span className='spinner'></span> Loading...</React.Fragment>
          :
          this.state.hierarchicalProjects && this.state.hierarchicalProjects.length>0 ?
            <ul className={`tree tree-expandable`}>
              {this.renderHierarchy(this.state.hierarchicalProjects)}
            </ul>
            :
            'None available.'
        }
      </React.Fragment>
    )
  }
}
