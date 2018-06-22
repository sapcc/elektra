import * as constants from '../constants';
import { ajaxHelper } from 'ajax_helper';

//################### COST REPORT #########################

const getChartData = function(data, services, serviceMap) {
  // init data to have allways 12 months with all services
  let resultData = {}
  let now = new Date()
  for (let i = 0; i <= 11; i++) {
    let past = new Date(now)
    past.setMonth(now.getMonth() - i)
    let date = past.getFullYear() + '/' + (past.getMonth()+1) // +1 to get the month from 1-12
    resultData[date] = {date: date}
    resultData[date]["rawData"] = []
    resultData[date]["total"] = 0
    services.map(i => resultData[date][i] = 0)
  }

  // add prices per service and add to total per month
  data.map(i => {
    let date = i.year + "/" + i.month
    if (resultData[date]) {
      if (services.includes(serviceMap[i.service])){
        resultData[date][serviceMap[i.service]] += i.price_loc // total per service
        resultData[date]["total"] += i.price_loc // total per month
        resultData[date]["rawData"].push(i)
      }
    }
  })

  return resultData
};

const getServiceMap = function(data) {
  const services = data.map(i => i.service).filter((item, pos, arr) => arr.indexOf(item)==pos)
  // add prices per service to find the ones with less amount
  let serviceAddedHash = {}
  data.map(i => {
    if(!serviceAddedHash[i.service]) {
      serviceAddedHash[i.service]={key:i.service, total:0}
    }
    serviceAddedHash[i.service]["total"] += i.price_loc // no price_sec use for now
  })
  // convert to array
  let serviceAddedArray = Object.keys(serviceAddedHash).map(i => serviceAddedHash[i])
  // sort
  serviceAddedArray.sort((a, b) => a.total - b.total).reverse()
  // build service map
  let serviceMap = {}
  // allow max of 5 services
  if (services.length > 5) {
    serviceAddedArray.map((item, index) => {
        if(index > 3) {
          return serviceMap[item.key] = "others"
        }
        return serviceMap[item.key] = item.key
      }
    )
  } else {
    serviceAddedArray.map(item => {
        return serviceMap[item.key] = item.key
      }
    )
  }
  return serviceMap
};

const getServices= function(servicesMap) {
  return Object.keys(servicesMap).map(i => servicesMap[i]).filter((item, pos, arr) => arr.indexOf(item)==pos)
};


const calcServiceMap= (servicesMap) => (
  {
    type: constants.CALC_SERVICE_MAP_COST_REPORT,
    serviceMap: servicesMap
  }
);

const calcServices= (servicesArray) => (
  {
    type: constants.CALC_SERVICES_COST_REPORT,
    services: servicesArray
  }
);

const calcChartData= (chartData) => (
  {
    type: constants.CALC_CHARTDATA_COST_REPORT,
    chartData: chartData
  }
);

const requestCostReport= () => (
  {
    type: constants.REQUEST_COST_REPORT,
    requestedAt: Date.now()
  }
);

const receiveCostReport= (json) => (
  {
    type: constants.RECEIVE_COST_REPORT,
    data: json,
    receivedAt: Date.now()
  }
);

const requestCostReportFailure= (err) => (
  {
    type: constants.REQUEST_COST_REPORT_FAILURE,
    error: err
  }
);

const fetchCostReport= (value) => (
  (dispatch,getState) =>
    new Promise((handleSuccess,handleErrors) => {
      dispatch(requestCostReport())
      ajaxHelper.get(`/`).then((response) => {
        if (response.data.errors) {
          dispatch(requestCostReportFailure(`Could not load report (${response.data.errors})`))
        }else {
          const serviceMap = getServiceMap(response.data)
          dispatch(calcServiceMap(serviceMap))
          const services = getServices(serviceMap)
          dispatch(calcServices(services))
          const chartData = getChartData(response.data, services, serviceMap)
          dispatch(calcChartData(chartData))
          dispatch(receiveCostReport(response.data))
          handleSuccess()
        }
      }).catch(error => {
        dispatch(requestCostReportFailure(`Could not load report (${error.message})`))
      })
    })
);

export {
  fetchCostReport
}
