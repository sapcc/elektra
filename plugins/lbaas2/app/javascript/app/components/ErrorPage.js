import React from 'react';

const ErrorPage = (error) => {
  console.log("RENDER error page")

  // const errorMessage = (error) =>
  //   error.data && (error.data.errors || error.data.error) ||
  //   error.message

  const errorCode = (error) => {
    return JSON.stringify(error)
  }

  return ( 
    <React.Fragment>
      <h1>
        <span className="fa fa-bug fa-w-16 fa-lg"></span>
        Oops!!
      </h1>
      <p>{errorCode(error)}</p>
      
    </React.Fragment>
   );
}
 
export default ErrorPage;