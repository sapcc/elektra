import { Graph } from './graph'

export default class App extends React.Component {
  state = {
    filterCollapsed: true,
    selectedTypes: {}
  }

  static defaultProps = {
    showFilter: true
  }

  componentDidMount(){
    this.props.loadRelatedObjects(this.props.objectId)
    if (this.props.objects) {
      this.setInitialSelectedTypes(this.props.objects)
    }
  }

  componentWillUnmount(){
    this.props.resetState()
    this.setState({filterCollapsed: true, selectedTypes: {}})
  }

  componentWillReceiveProps(nextProps) {
    if (Object.keys(this.state.selectedTypes).length==0 && nextProps.objects) {
      this.setInitialSelectedTypes(nextProps.objects)
    }
  }

  setInitialSelectedTypes = (objects) => {
    const availableObjectTypes = {}
    for(let obj of Object.values(objects)) {
      if(obj.cached_object_type) {
        availableObjectTypes[obj.cached_object_type] = true
      }
    }
    this.setState({selectedTypes: availableObjectTypes})
  }

  convertObjectToNodes = () => {
    let nodes = {}
    let links = []

    if(this.props.objects) {
      for(let node of Object.values(this.props.objects)) {
        let newNode = { ...(node.payload || node),
          label: Graph.nodeLabel(node),
          isFetching: node.isFetching
        }
        if(this.state.selectedTypes[newNode.cached_object_type]) {
          nodes[node.id] = newNode
        }
      }

      for(let node of Object.values(this.props.objects)) {
        for(let childId of node.children) {
          if(nodes[node.id] && nodes[childId]) {
            links.push({source: node.id, target: childId})
          }
        }
      }
    }

    return [Object.values(nodes),links]
  }

  toggleFilter = () => {
    this.setState({filterCollapsed: !this.state.filterCollapsed})
  }

  updateSelectedTypes = (type) => {
    const selectedTypes = { ...this.state.selectedTypes}
    selectedTypes[type] = !selectedTypes[type]
    this.setState({selectedTypes})
  }

  availableObjectTypes = () => {
    if (!this.props.objects) return []
    return Object.values(this.props.objects).map(obj =>
      obj.cached_object_type
    ).filter( (elem, pos,arr) => arr.indexOf(elem) == pos)
  }

  render() {
    const options = this.availableObjectTypes()
    const graphData = this.convertObjectToNodes()

    return (
      <React.Fragment>
        <div className='toolbar'>
          <label>Show:</label>

          <div
            className={`dropdown ${ this.state.filterCollapsed ? '' : 'open'}`}
            tabIndex="0"
            onBlur={() => console.log('filter onBlur')}>
            <button
              className="btn btn-default"
              type="button"
              onClick={this.toggleFilter}>
              Select ...
              <span className="caret"></span>
            </button>
            <ul className="dropdown-menu" style={{maxHeight: 300, overflow: 'auto'}} >
              {options.map((option,index) =>
                <li key={index}>
                  <a href='#' onClick={(e) => {e.preventDefault(); this.updateSelectedTypes(option)}}>
                    <i className={`fa fa-fw fa-${this.state.selectedTypes[option] ? 'check-' : ''}square-o`}></i>
                    <span>{option}</span>
                  </a>
                </li>
              )}
            </ul>
          </div>
        </div>

        <Graph
          nodes={graphData[0]}
          links={graphData[1]}
          width={1138}
          height={600}
          loadRelatedObjects={this.props.loadRelatedObjects}/>
      </React.Fragment>
    )
  }
}
