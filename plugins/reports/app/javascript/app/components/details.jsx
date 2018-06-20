import { scaleOrdinal } from 'd3-scale'
import { CSSTransition, TransitionGroup } from 'react-transition-group';
import ServiceDetail from './serviceDetail'

const DetailsViewFadeTransition = ({
  children,
  ...props
}) => (<CSSTransition {...props} timeout={300} unmountOnExit classNames="css-transition-fade">
  {children}
</CSSTransition>);

const DetailsViewHighlightTransition = ({
  children,
  ...props
}) => (<CSSTransition {...props} timeout={300} unmountOnExit classNames="css-transition-highlight">
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

  renderTableService = (service, clickService) => {
    if (clickService == this.props.serviceMap[service.service] || clickService == "all") {
      return (<DetailsViewFadeTransition key={service.service+service.measure}>
                <ServiceDetail service={service} getColor={this.getColor}/>
              </DetailsViewFadeTransition>)
    }
  }

  render() {
    const {data,showDetails,clickService} = this.props
    return (
      <DetailsViewFadeTransition in={showDetails}>
          <div>
            {data &&
              <h3>
                <TransitionGroup>
                  Details for <DetailsViewHighlightTransition key={data.date}><b>{data && data.date}</b></DetailsViewHighlightTransition>
                </TransitionGroup>
                <button aria-label="Close" onClick={(e)=>this.onClose(e)} className="close" type="button">
                  <span aria-hidden="true">×</span>
                </button>
              </h3>
            }
            <TransitionGroup className="details-container" >
              {data && data.rawData.map(service => (
                this.renderTableService(service,clickService)
              ))}
            </TransitionGroup>
        </div>
      </DetailsViewFadeTransition>
    )
  }
}
export default Details;
