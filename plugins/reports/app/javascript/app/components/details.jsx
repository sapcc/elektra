import { scaleOrdinal } from 'd3-scale'
import { CSSTransition, TransitionGroup } from 'react-transition-group';

const DetailsViewFadeTransition = ({
  children,
  ...props
}) => (<CSSTransition {...props} timeout={300} unmountOnExit classNames="css-transition-fade">
  {children}
</CSSTransition>);

const DetailsViewHighlightTransition = ({
  children,
  ...props
}) => (<CSSTransition {...props} unmountOnExit classNames="css-transition-highlight">
  {children}
</CSSTransition>);



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
      <DetailsViewFadeTransition in={this.props.showDetails}>
          <div>
            <h3>
              Details for <b>{data && data.date}</b>
            <button aria-label="Close" onClick={(e)=>this.onClose(e)} className="close" type="button">
                <span aria-hidden="true">×</span>
              </button>
            </h3>
            <TransitionGroup className="details-container">
              {data && data.rawData.map((service, index) => (
                <DetailsViewFadeTransition key={service+index}>
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
                                  <DetailsViewHighlightTransition key={service+key+service[key]}>
                                    <span>{service[key]}</span>
                                  </DetailsViewHighlightTransition>
                                </TransitionGroup>
                              </td>
                            </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </DetailsViewFadeTransition>
              ))}
            </TransitionGroup>
        </div>
      </DetailsViewFadeTransition>
    )
  }
}
export default Details;
