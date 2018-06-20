import { CSSTransition, TransitionGroup } from 'react-transition-group';

const DetailsViewHighlightTransition = ({
  children,
  ...props
}) => (<CSSTransition {...props} timeout={300} unmountOnExit classNames="css-transition-highlight">
  {children}
</CSSTransition>);

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
            <tr key={props.service+key}>
              <th>{key}</th>
              <td>
                <TransitionGroup>
                  <DetailsViewHighlightTransition key={props.service+key+props.service[key]}>
                    <span>{props.service[key]}</span>
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
