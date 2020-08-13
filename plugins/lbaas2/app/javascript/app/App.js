import { StateProvider } from "./components/StateProvider"
import reducers from "./reducers"
import Router from "./components/Router"
// import { FlashMessages } from 'lib/flashes';
import FloatingFlashMessages from "./components/shared/FloatingFlashMessages"

const App = () => {
  console.log("RENDER App")
  return (
    <React.Fragment>
      <div className="bs-callout bs-callout-info bs-callout-emphasize">
        <p>
          This is the new beta UI based on Octavia driver for Neutron LBaaS.
          Feel free to try it! We are happy to get your feedback on our slack
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
