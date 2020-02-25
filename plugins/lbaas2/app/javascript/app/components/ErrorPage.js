import React, { useState } from 'react';
import { Button } from 'react-bootstrap'

const ErrorPage = ({error, headTitle}) => {
  console.log("RENDER error page")

  const [showDetails, setShowDetails] = useState(false)
  const err = error.error || error

  const httpStatus = () => {
    return err && err.status || err.status
  }

  const title = () => {
    return err.statusText
  }

  const description = () => {
    switch (httpStatus(error)) {
      case '500':
        return "There was an error. Please try later again"
      default:
        return "There was an error. Please try again later"
    }
  }

  const details = () => {
    return err.data &&  (err.data.errors || err.data.error) || err.message
  }

  const handleDetails = (e) => {    
    if(e) e.stopPropagation()
    setShowDetails(!showDetails)
  }

  return ( 
    <React.Fragment>
      <div className="row">
        <div className="col-md-10 col-md-offset-2">
          <div className="row">
            <div className="col-md-10">
              <h1>LBaaS - {headTitle}</h1>
              <p><b>{httpStatus()}</b> {title()}</p>
              <p>{description()}</p>
              <Button bsStyle="link" className="details-link" onClick={handleDetails} >Details</Button>
              {showDetails &&
                <pre>
                  <code>{details()}</code>
                </pre>
              }
            </div>
          </div>
        </div>
      </div>
    </React.Fragment>
   );
}
 
export default ErrorPage;