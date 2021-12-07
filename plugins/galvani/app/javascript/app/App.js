import { StateProvider } from "./components/StateProvider"
import reducers from "./reducers"
import TagsList from "./components/TagsList"

const App = () => {
  return (
    <React.Fragment>
      <h1>Hello</h1>
      <TagsList />
    </React.Fragment>
  )
}

export default () => (
  <StateProvider reducers={reducers}>
    <App />
  </StateProvider>
)
