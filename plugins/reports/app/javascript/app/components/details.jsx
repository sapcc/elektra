import { scaleOrdinal } from 'd3-scale'
import { CSSTransition } from 'react-transition-group';

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
      <React.Fragment>
        {data &&
          <React.Fragment>
            <h3>
              Details for <b>{data.date}</b>
            <button aria-label="Close" onClick={(e)=>this.onClose(e)} className="close" type="button">
                <span aria-hidden="true">×</span>
              </button>
            </h3>

          </React.Fragment>
        }
        <CSSTransition
          in={data != null}
          timeout={300}
          classNames="details-container"
          unmountOnExit>
          <div className="details-container">
            {data && data.rawData.map((service, index) => (
              <div className="service-details" key={service+index}>
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
                        <td>{service[key]}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ))}
          </div>
        </CSSTransition>
      </React.Fragment>
    )
  }
}
export default Details;
