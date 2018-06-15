import { ResponsiveBar } from '@nivo/bar'
import Legend from './legend'
import { scaleOrdinal } from 'd3-scale'
import { CSSTransition } from 'react-transition-group';

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
        if (services.includes(serviceMap[i.service])){
          resultData[date][serviceMap[i.service]] += i.price_loc + i.price_sec
          resultData[date]["rawData"].push(i)
        }
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

  onClickRect = (recData) => {
    const data = this.setUpData()
    let rawData = data[recData.indexValue]["rawData"]
    this.props.onClick({date: recData.indexValue, rawData: rawData})
  }

  getServiceByColor = (color) => {
    const colorScale = scaleOrdinal()
      .domain(this.props.cost.services)
      .range(this.props.colors)
    let colorIndex = colorScale.range().indexOf(color)
    return colorScale.domain()[colorIndex]
  }

  render() {
    const {data,services,isFetching,serviceMap} = this.props.cost

    // barComponent={RectBarComponent}
    const RectBarComponent = ({ x, y, width, height, color, data, onClick, tooltip, showTooltip, hideTooltip}) => {
      const {clickService,clickedBar} = this.props
      let service = this.getServiceByColor(color)
      const handleTooltip = e => showTooltip(CustomTooltip(data, color), e)

      let newY = (service === clickService) ? 240-height : y
      let opacity = (clickService !== "all" && service !== clickService) ? 0 : 1
      opacity = (opacity == 1 && clickedBar!== "none" && data.indexValue !== clickedBar) ? 0.5 : opacity

      // hide hideTooltip
      if (opacity == 0) {
        return <rect width={width} height={height} x={x} y={newY} fill={color} opacity={opacity} onClick={() => onClick(data)}/>
      }

      return <rect width={width} height={height} x={x} y={newY} fill={color} opacity={opacity} onClick={() => onClick(data)}
                onMouseEnter={handleTooltip}
                onMouseMove={handleTooltip}
                onMouseLeave={hideTooltip}/>
    }

    const CustomTooltip = (node, color) => (
        <div
            style={{
                fontFamily: "SFMono-Regular,Consolas,Liberation Mono,Menlo,Courier,monospace",
                fontSize: "11px",
                fontWeight: "normal",
                color: "#fff",
                display: 'grid',
                gridTemplateColumns: '1fr 1fr',
                gridColumnGap: '12px',
                background: "#333",
                padding: "8px",
                borderRadius: "3px"
            }}
        >
            <span style={{ fontWeight: 500 }}>Service</span>
            <span><i className="fa fa-square header-square" style={{color: color}}/> {node.id}</span>
            <span style={{ fontWeight: 500 }}>Value</span>
            <span>{node.value}</span>
        </div>
    )


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
                  barComponent={RectBarComponent}
                />
              </div>
            </div>
            <div className="col-sm-2 col-xs-2">
              <Legend height="300" colors={this.props.colors} services={services} serviceMap={serviceMap} onClickLegend={this.props.onClickLegend}/>
            </div>
          </div>

        }
      </React.Fragment>
    )
  }
}
export default NivoBarChart;
