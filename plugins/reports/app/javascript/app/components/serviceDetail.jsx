import { CSSTransition, TransitionGroup } from 'react-transition-group';

const DetailsViewHighlightTransition = ({
  children,
  ...props
}) => (<CSSTransition {...props} timeout={300} unmountOnExit classNames="css-transition-highlight">
  {children}
</CSSTransition>);

const blackListKeys = ["region", "year", "month", "project_id"]

const ServiceDetail = props => (
  <div className="service-details">
    <table className="table datatable">
      <thead>
        <tr>
          <th colSpan="2">
            <i className="fa fa-square header-square" style={{color: props.getColor(props.service["service"])}}/>
            <span>{props.service["service"]}</span>
          </th>
        </tr>
      </thead>
      <tbody>
        {Object.keys(props.service).map(key => (
            !blackListKeys.includes(key) &&
            <tr className={(key == "price_loc" || key == "price_sec") ? "heighlight" : "undefined"} key={props.service+key}>
              <th>{key}</th>
              <td>
                <TransitionGroup>
                  <DetailsViewHighlightTransition key={props.service+key+props.service[key]}>
                    <span>{parseFloat(props.service[key]).toFixed(2)}</span>
                  </DetailsViewHighlightTransition>
                </TransitionGroup>
              </td>
            </tr>
        ))}
      </tbody>
    </table>
  </div>
);

export default ServiceDetail;
