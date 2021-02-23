import { StateProvider } from "./components/StateProvider"
import reducers from "./reducers"
import Router from "./components/Router"
import FloatingFlashMessages from "./components/shared/FloatingFlashMessages"
import Log from "./components/shared/logger"

const App = () => {
  Log.debug("RENDER App")
  return (
    <React.Fragment>
      <div className="bs-callout bs-callout-info bs-callout-emphasize">
        <p>
          This is the new UI based on Octavia driver for Neutron LBaaS.
          We are happy to get your feedback on our slack
          channel{" "}
          <a href="https://convergedcloud.slack.com/archives/C018SPLDB9Q">
            #octavia-users
          </a>
          .
        </p>
      </div>

      <FloatingFlashMessages />
      <Router />
    </React.Fragment>
  )
}

export default () => (
  <StateProvider reducers={reducers}>
    <App />
  </StateProvider>
)
