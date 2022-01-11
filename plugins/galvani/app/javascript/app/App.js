import { StateProvider } from "./components/StateProvider"
import reducers from "./reducers"
import AccessProfilesList from "./components/AccessProfilesList"
import Config from "./components/Config"
import FloatingFlashMessages from "./components/shared/FloatingFlashMessages"

const App = () => {
  return (
    <>
      <FloatingFlashMessages />
      <div className="modal-body">
        <h4>Enable external access for Converged Cloud APIs</h4>
        <p>
          By enabling access profiles you can make a subset of converged cloud
          APIs available to the public Internet within the scope of your
          project. As an example this gives you the opportunity to enabled
          pulling/pushing of container images your Keppel account from the
          public internet. Check out our documentation about external access
          policies to learn more.
        </p>

        <Config />
        <AccessProfilesList />
      </div>
    </>
  )
}

export default () => (
  <StateProvider reducers={reducers}>
    <App />
  </StateProvider>
)
