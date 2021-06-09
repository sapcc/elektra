import { useEffect } from "react";

const usePolling = ({ delay, callback, active }) => {
  useEffect(() => {
    if (!delay || delay <= 0 || !active) return;
    const promiseCanceledError = "promiseCanceled";
    let timeoutId = null;
    let pollingActive = true;
    let newDelay = delay;
    let errorRetries = 0;

    const poll = () => {
      console.log("polling with delay: ", newDelay);
      callback()
        .then((data) => {
          // check if the promise was canceled
          if (!pollingActive) throw promiseCanceledError;
          return data;
        })
        .then(() => {
          // restore default values
          newDelay = delay;
          errorRetries = 0;
          // poll again
          clearTimeout(timeoutId);
          timeoutId = setTimeout(poll, newDelay);
        })
        .catch((reason) => {
          if (reason !== promiseCanceledError && errorRetries < 3) {
            // increase polling delay if error different the canceled promise and less than 5 retries
            errorRetries = errorRetries + 1;
            newDelay = newDelay * 2;
            clearTimeout(timeoutId);
            timeoutId = setTimeout(poll, newDelay);
          }
        });
    };

    // initial polling
    timeoutId = setTimeout(poll, newDelay);

    return function cleanup() {
      // cancel the promise
      pollingActive = false;
      // clear timeout
      clearTimeout(timeoutId);
    };
  }, [delay, active, callback]);
};

export default usePolling;
