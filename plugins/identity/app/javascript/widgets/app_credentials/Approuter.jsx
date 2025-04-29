import React from "react"
import { useState } from "react"
import { BrowserRouter, Route } from "react-router-dom"
import { widgetBasePath } from "lib/widget"
import List from "./List"
import New from "./New"
import Show from "./Show"

const baseName = widgetBasePath("app-credentials")

const AppRouter = ({ userId, projectId }) => {
  //console.log("userID", userId)
  //console.log("baseName", baseName)
  const [refreshRequestedAt, setRequestedAt] = useState(new Date().getTime())
  const [overlay, setOverlay] = useState(false)

  // this will trigger a refresh of the list
  const refreshList = () => {
    setRequestedAt(new Date().getTime())
  }

  return (
    <>
      <div className={overlay ? "app-credentials-overlay" : ""} />
      <BrowserRouter basename={baseName}>
        <Route
          path="/"
          render={() => <List userId={userId} projectId={projectId} refreshRequestedAt={refreshRequestedAt} />}
        />
        <Route
          exact
          path="/create"
          render={() => <New userId={userId} refreshList={refreshList} setOverlay={setOverlay} />}
        />
        <Route exact path="/:id/show" render={() => <Show userId={userId} />} />
      </BrowserRouter>
    </>
  )
}

export default AppRouter
