import { ResponsiveBar } from '@nivo/bar'

class NivoBarChart extends React.Component {

  setUpData = () => {
    const data = this.props.cost.data

    // init data to have allways 12 months with all services
    let resultData = {}
    let now = new Date()
    for (let i = 0; i <= 11; i++) {
      let past = new Date(now)
      past.setMonth(now.getMonth() - i)
      let date = past.getFullYear() + '/' + (past.getMonth()+1) // +1 to get the month from 1-12
      resultData[date] = {date: date}
      resultData[date]["rawData"] = []
      this.props.services().map(i => resultData[date][i] = 0)
    }

    // add prices per service and add to total per month
    data.map(i => {
      let date = i.year + "/" + i.month
      if (resultData[date]) {
        resultData[date][i.service] += i.price_loc + i.price_sec
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
    console.log()
    const data = this.setUpData()
    let rawData = data[recData.indexValue]["rawData"]
    this.props.onClick({date: recData.indexValue, rawData: rawData})
  }

  render() {
    return (
      <React.Fragment>
        {this.props.cost.isFetching &&
          <div>
            Loading
            <span className="spinner"/>
          </div>
        }
        {this.props.cost.data &&
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
              keys={this.props.services()}
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
        }
      </React.Fragment>
    )
  }
}
export default NivoBarChart;
