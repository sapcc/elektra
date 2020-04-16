import React, { useState } from 'react';
import { Button } from 'react-bootstrap'
import { Link } from 'react-router-dom';

const ErrorPage = ({error, headTitle, onReload}) => {
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
    const generalError = <React.Fragment>
      <p>There was an error. Don't worry, it's not you - it's us. Sorry about that.</p>
      <p>
      <span>Please try later again</span>
      {onReload &&
        <React.Fragment>
          <span> or try reloading </span>
          <div className="ep-reload-button">
            <Button bsStyle="btn btn-primary" onClick={onReload} >Reload <i className="fa fa-refresh"></i></Button>
          </div>          
        </React.Fragment>
      }
      </p>  
    </React.Fragment>

    switch (httpStatus()) {
      case 500:
        return generalError
      case 404:
        return <p>That’s an error. The requested entity was not found</p>
      default:
        return generalError
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
            <div className="col-md-10 ep">
              <h1>LBaaS - {headTitle}</h1>
              <p><b>{httpStatus()}</b> {title()}</p>
              {description()}            
              {details() &&
                <React.Fragment>
                  <Button bsStyle="link" className="ep-details-link" onClick={handleDetails} >Details</Button>
                  {showDetails && 
                    <pre>
                      <code>{details()}</code>
                    </pre>
                  }
                </React.Fragment>
              }
            </div>
          </div>
        </div>
      </div>
    </React.Fragment>
   );
}
 
export default ErrorPage;