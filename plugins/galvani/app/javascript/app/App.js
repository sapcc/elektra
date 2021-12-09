import { StateProvider } from "./components/StateProvider"
import reducers from "./reducers"
import TagsList from "./components/TagsList"
import Config from "./components/Config"

const App = () => {
  return (
    <div className="modal-body">
      <h4>Enable external access for converged cloud APIs</h4>
      <p>
        By enabling access profiles you can make a subset of converged cloud
        APIs available to the public Internet within the scope of your project.
        As an example this gives you the opportunity to enabled pulling/pushing
        of container images your Keppel account from the public internet. Check
        out our documentation about external access policies to learn more.
      </p>

      <Config />
      <TagsList />
    </div>
  )
}

export default () => (
  <StateProvider reducers={reducers}>
    <App />
  </StateProvider>
)
