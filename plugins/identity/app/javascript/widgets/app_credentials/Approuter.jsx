import React from "react"
import { useState } from "react"
import { BrowserRouter, Route } from "react-router-dom"
import { widgetBasePath } from "lib/widget"
import List from "./List"
import New from "./New"

const baseName = widgetBasePath("app-credentials")

const AppRouter = ({ userId }) => {
  //console.log("userID", userId)
  //console.log("baseName", baseName)
  const [refreshRequestedAt, setRequestedAt] = useState(new Date().getTime())

  // this will trigger a refresh of the list
  const refreshList = () => {
    setRequestedAt(new Date().getTime())
  }

  return (
    <>
      <BrowserRouter basename={baseName}>
        <Route path="/" render={() => <List userId={userId} refreshRequestedAt={refreshRequestedAt} />} />
        <Route exact path="/new" render={() => <New userId={userId} refreshList={refreshList} />} />
      </BrowserRouter>
    </>
  )
}

export default AppRouter
