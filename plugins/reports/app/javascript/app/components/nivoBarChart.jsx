import { ResponsiveBar } from '@nivo/bar'
import Legend from './legend'

class NivoBarChart extends React.Component {

  setUpData = () => {
    const {data, services, serviceMap} = this.props.cost

    // init data to have allways 12 months with all services
    let resultData = {}
    let now = new Date()
    for (let i = 0; i <= 11; i++) {
      let past = new Date(now)
      past.setMonth(now.getMonth() - i)
      let date = past.getFullYear() + '/' + (past.getMonth()+1) // +1 to get the month from 1-12
      resultData[date] = {date: date}
      resultData[date]["rawData"] = []
      services.map(i => resultData[date][i] = 0)
    }

    // add prices per service and add to total per month
    data.map(i => {
      let date = i.year + "/" + i.month
      if (resultData[date]) {
        resultData[date][serviceMap[i.service]] += i.price_loc + i.price_sec
        resultData[date]["rawData"].push(i)
      }
    })

    return resultData
  }

  //
  // Remove keys to have just an array of objects
  // Reverse array to go from the past to the present
  //
  getData = () => {
    const data = this.setUpData()
    let resultArray = Object.keys(data).map(i => data[i])
    return resultArray.reverse()
  }

  onClickRect = (recData, event) => {
    const data = this.setUpData()
    let rawData = data[recData.indexValue]["rawData"]
    this.props.onClick({date: recData.indexValue, rawData: rawData})
  }

  render() {
    const {data,services,isFetching,serviceMap} = this.props.cost
    return (
      <React.Fragment>
        {isFetching &&
          <div>
            Loading
            <span className="spinner"/>
          </div>
        }
        {data && services && serviceMap &&
          <div className="row">
            <div className="col-sm-10 col-xs-10">
              <div className="barChart">
                <ResponsiveBar
                  data={this.getData()}
                  colors={this.props.colors}
                  margin={{
                    top: 30,
                    bottom: 30,
                    left: 40
                  }}
                  axisLeft={{
                      "orient": "left",
                      "tickSize": 5,
                      "tickPadding": 5,
                      "tickRotation": 0,
                      "legend": "EUR",
                      "legendPosition": "center",
                      "legendOffset": -30
                  }}
                  indexBy="date"
                  keys={services}
                  padding={0.2}
                  labelTextColor="inherit:darker(1.4)"
                  labelSkipWidth={16}
                  labelSkipHeight={16}
                  animate={true}
                  motionStiffness={90}
                  motionDamping={15}
                  enableLabel={false}
                  onClick={this.onClickRect}
                />
              </div>
            </div>
            <div className="col-sm-2 col-xs-2">
              <Legend height="300" colors={this.props.colors} services={services} serviceMap={serviceMap}/>
            </div>
          </div>

        }
      </React.Fragment>
    )
  }
}
export default NivoBarChart;
