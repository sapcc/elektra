import ProjectDetails from './projectDetails';

class App extends React.Component {

  state = {
    value: '',
    error: null
  };

  handleChange = (event) => {
    const newState = {}
    newState[event.currentTarget.name] = event.currentTarget.value
    this.setState(newState)
  }

  onSubmit = (event) => {
    event.preventDefault();
    this.props.handleSubmit(this.state.value).catch(({errors}) => {
      this.setState({error: errors})
    })
  }

  render() {
    return (
      <React.Fragment>
        <div className={this.props.modal ? 'modal-body' : ''}>
          <form action="" className="form-horizontal">
            {this.state.error &&
              <div className="alert alert-error">
                {this.state.error}
              </div>
            }
            <div className="form-group">
              <label
                htmlFor="reverseLookupValue"
                className="col-sm-4 control-label">
                Enter Child IP or DNS
              </label>
              <div className="col-sm-6">
                <input
                  className="form-control"
                  name="value"
                  id="reverseLookupValue"
                  type="text"
                  value={this.state.name}
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
          {this.props.isFetching &&
            <span className="spinner">
            </span>
          }
          { this.props.project.data &&
            <ProjectDetails project={this.props.project.data}/>
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
