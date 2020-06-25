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
    const serverError = <React.Fragment>
      <p>There was an error. Don't worry, it's not you - it's us. Sorry about that.</p>
      <p>
        Please try later again
        {onReload &&
          <React.Fragment>
            <span> or try reloading</span>
          </React.Fragment>
        }
      </p>
      {onReload && 
        <div className="ep-reload-button">
          <Button bsStyle="primary" onClick={onReload} >Reload <i className="fa fa-refresh"></i></Button>
        </div> 
      }
    </React.Fragment>

    if (httpStatus() >= 500) {
      return serverError
    } else if(httpStatus() >= 400 && httpStatus() < 500) {
      return ""
    } else if(httpStatus() == 404) {
      return <p>That’s an error. The requested entity was not found</p>
    }else {
      return serverError
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
              <h2>LBaaS - {headTitle}</h2>
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