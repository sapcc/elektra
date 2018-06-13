import { scaleOrdinal } from 'd3-scale'
import { CSSTransition, TransitionGroup } from 'react-transition-group';

class Details extends React.Component {

  getColor = (service) => {
    const scale = scaleOrdinal()
      .domain(this.props.services)
      .range(this.props.colors)
    const serviceMap = this.props.serviceMap
    return scale(serviceMap[service])
  }

  onClose = (event) => {
    event.preventDefault();
    this.props.onClose()
  }

  render() {
    const data = this.props.data
    return (
      <CSSTransition
        in={this.props.showDetails}
        timeout={300}
        classNames="details-container"
        unmountOnExit>
          <div>
            <h3>
              Details for <b>{data && data.date}</b>
            <button aria-label="Close" onClick={(e)=>this.onClose(e)} className="close" type="button">
                <span aria-hidden="true">×</span>
              </button>
            </h3>
            <div className="details-container">
              <TransitionGroup>
                {data && data.rawData.map((service, index) => (
                  <CSSTransition
                    key={service+index}
                    timeout={300}
                    classNames="details-container"
                    unmountOnExit>
                    <div className="service-details">
                      <table className="table datatable">
                        <thead>
                          <tr>
                            <th colSpan="2">
                              <i className="fa fa-square header-square" style={{color: this.getColor(service["service"])}}/>
                              <span>{service["service"]}</span>
                            </th>
                          </tr>
                        </thead>
                        <tbody>
                          {Object.keys(service).map(key => (
                              <tr key={service+key}>
                                <th>{key}</th>
                                <td>
                                  <TransitionGroup>
                                    <CSSTransition
                                      key={service+key+service[key]}
                                      timeout={300}
                                      classNames="details-container"
                                      unmountOnExit>
                                      <span>{service[key]}</span>
                                    </CSSTransition>
                                  </TransitionGroup>
                                </td>
                              </tr>
                          ))}
                        </tbody>
                      </table>
                    </div>
                  </CSSTransition>
                ))}
                </TransitionGroup>
          </div>
        </div>
      </CSSTransition>
    )
  }
}
export default Details;
