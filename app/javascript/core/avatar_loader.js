window.loadAvatar = function ({ avatarUrl, elementId }) {
  const executeLoad = () => {
    // Defer image loading until browser is idle, otherwise it may block other javascript execution
    // In our case, if the image loading ran into a timeout, the auth_projects fetch would be blocked until the timeout was reached
    requestIdleCallback(() => { 
      const img = new Image();
      let isHandled = false;

      const handleFailure = () => {
        if (!isHandled) {
          isHandled = true;
          console.warn(`Avatar image ${avatarUrl} did not load in time, using default image.`);
        }
      };

      img.onload = function () {
        if (!isHandled) {
          isHandled = true;
          const container = document.getElementById(elementId);
          if (container) {
            container.appendChild(img); 
          }
          console.info(`Successfully loaded avatar from ${avatarUrl}.`);
        }
      };

      img.onerror = handleFailure;

      // Fail fast if image doesn't load in 5 seconds
      setTimeout(handleFailure, 5000);

      img.src = avatarUrl; // Start loading the image
    }, { timeout: 5000 }); // Wait up to 5 seconds before forcing execution
  };

  // Ensure DOM is ready before running loadAvatar
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", executeLoad);
  } else {
    executeLoad();
  }
};
