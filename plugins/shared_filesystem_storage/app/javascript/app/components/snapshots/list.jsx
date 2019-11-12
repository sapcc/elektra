import SnapshotItem from './item';

export default class SnapshotList extends React.Component {
  constructor(props){
  	super(props);
  	this.share = this.share.bind(this)
  }

  componentDidMount() {
    if(this.props.active) this.props.loadSnapshotsOnce()
  }

  UNSAFE_componentWillReceiveProps(nextProps) {
    if(nextProps.active) this.props.loadSnapshotsOnce()
  }

  share(snapshot){
    if(this.props.shares.isFetching) return 'loading'
    return this.props.shares.items.find(i=>i.id==snapshot.share_id)
  }

  render(){
    if (this.props.isFetching) {
      return <div><span className='spinner'></span>Loading...</div>
    }
    return (
      <table className='table snapshots'>
        <thead>
          <tr>
            <th>Name</th>
            <th>Source</th>
            <th>Size</th>
            <th>Status</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          { this.props.snapshots.length==0 &&
            <tr><td colSpan="5">No Snapshots found.</td></tr>
          }
          {this.props.snapshots.map(snapshot =>
            <SnapshotItem
              key={snapshot.id}
              snapshot={snapshot}
              share={this.share(snapshot)}
              handleDelete={this.props.handleDelete}
              reloadSnapshot={this.props.reloadSnapshot}/>
          )}
        </tbody>
      </table>
    )
  }
}
