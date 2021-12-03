import { StateProvider } from "./components/StateProvider"
import reducers from "./reducers"
import Tags from "./components/Tags"

const App = () => {
  return (
    <React.Fragment>
      <h1>Hello</h1>
      <Tags />
    </React.Fragment>
  )
}

export default () => (
  <StateProvider reducers={reducers}>
    <App />
  </StateProvider>
)
