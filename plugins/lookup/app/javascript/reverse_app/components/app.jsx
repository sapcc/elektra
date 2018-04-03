// import ProjectDetails from './projectDetails';
import ProjectDetails from '../containers/projectDetails';
import { Form } from 'lib/elektra-form';

class App extends React.Component {

  state = {
    searchValue: "",
    error: null
  };

  handleChange = (event) => {
    const newState = {}
    newState[event.currentTarget.name] = event.currentTarget.value
    this.setState(newState)
  }

  onSubmit = (event) => {
    event.preventDefault();
    this.searchValue = this.state.value;
    this.setState({error: null})
    this.props.handleSubmit(this.state.searchValue).catch(({errors}) => {
      this.setState({error: errors})
    })
  }

  render() {
    return (
      <React.Fragment>
        <div className={this.props.modal ? 'modal-body' : ''}>
          <form action="" className="form-horizontal">
            <Form.Errors errors={this.state.error}/>
            <div className="form-group">
              <label
                htmlFor="reverseLookupValue"
                className="col-sm-4 control-label">
                Enter Child IP or DNS
              </label>
              <div className="col-sm-6">
                <input
                  className="form-control"
                  name="searchValue"
                  id="reverseLookupValue"
                  type="text"
                  value={this.state.searchValue}
                  onChange={this.handleChange}
                  />
              </div>
              <div className="col-sm-2">
                <button
                  className="btn btn-primary"
                  onClick={(e)=>this.onSubmit(e)}
                  disabled={this.props.isFetching}>
                  {this.props.isFetching ? 'Please wait...' : 'Find Project'}
                </button>
              </div>
            </div>
          </form>
          {this.props.project.isFetching &&
            <React.Fragment>
              <span>Loading details for <b>{this.state.searchValue}</b></span>
              <span className="spinner"/>
            </React.Fragment>
          }
          {this.props.project.error &&
            <span className="text-danger">
              {this.props.project.error}
            </span>
          }
          { this.props.project.data &&
            <ProjectDetails project={this.props.project.data} />
          }
        </div>
        {this.props.modal &&
          <div className="modal-footer">
            <button
              className="btn btn-default"
              type="button"
              data-dismiss="modal"
              aria-label="Cancel">
              Cancel
            </button>
          </div>
        }
      </React.Fragment>
    )
  }
}

export default App;
