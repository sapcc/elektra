import { Switch, Route, useRouteMatch } from "react-router-dom"

import NewObject from "./new"
import UploadFile from "./upload"

export default () => {
  let { path } = useRouteMatch()
  return (
    <Switch>
      <Route path={`${path}/new`} component={NewObject} />
      <Route path={`${path}/upload`} component={UploadFile} />
    </Switch>
  )
}
