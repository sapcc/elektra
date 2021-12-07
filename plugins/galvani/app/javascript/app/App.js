import { StateProvider } from "./components/StateProvider"
import reducers from "./reducers"
import TagsList from "./components/TagsList"

const App = () => {
  return (
    <React.Fragment>
      <TagsList />
    </React.Fragment>
  )
}

export default () => (
  <StateProvider reducers={reducers}>
    <App />
  </StateProvider>
)
