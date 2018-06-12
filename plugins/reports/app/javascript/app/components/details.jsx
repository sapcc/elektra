import { scaleOrdinal } from 'd3-scale'

class Details extends React.Component {

  setColorScale = () => {
    return scaleOrdinal()
      .domain(this.props.services())
      .range(this.props.colors)
  }

  getBackgroundColor = (service) => {
    let scale = this.setColorScale()
    return scale(service)
  }

  render() {
    const data = this.props.data
    return (
      <React.Fragment>
        {data &&
          <React.Fragment>
            <h3>Details for <b>{data.date}</b></h3>
          </React.Fragment>
        }
        <div className="details-container">
          {data && data.rawData.map((service, index) => (
            <div className="service-details" key={service+index}>
              <table className="table datatable">
                <thead>
                  <tr>
                    <th colSpan="2">
                      <i className="fa fa-square header-square" style={{color: this.getBackgroundColor(service["service"])}}/>
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
      </React.Fragment>
    )
  }
}
export default Details;
