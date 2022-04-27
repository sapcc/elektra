import { StateProvider } from "./components/StateProvider";
import reducers from "./reducers";
import Router from "./components/Router";
import FloatingFlashMessages from "./components/shared/FloatingFlashMessages";
import Log from "./components/shared/logger";

const App = () => {
  Log.debug("RENDER App");
  return (
    <React.Fragment>
      <FloatingFlashMessages />
      <Router />
    </React.Fragment>
  );
};

export default () => (
  <StateProvider reducers={reducers}>
    <App />
  </StateProvider>
);
