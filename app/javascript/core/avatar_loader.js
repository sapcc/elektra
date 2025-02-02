window.loadAvatar = function ({ avatarUrl, elementId }) {
  document.addEventListener("DOMContentLoaded", function () {
    const loadImage = new Promise((resolve, reject) => {
      var img = new Image()
      // handle the case where the image does not exist
      // try to load the image
      img.onload = function () {
        // if the image exists, set the src attribute of the image element
        // console.info(`Loading avatar image from ${avatarUrl} into element with id ${elementId}.`)
        document.getElementById(elementId).insertAdjacentHTML("beforeend", `<img src="${avatarUrl}" />`)
        resolve()
      }
      img.onerror = function () {
        // if the image does not exist, use the default image
        console.warn(`Avatar image ${avatarUrl} does not exist, using default image.`)
        reject()
      }
      // set the src attribute to the image url
      img.src = avatarUrl
    })

    loadImage
      .then(() => {
        console.info(`Successfully loaded avatar from ${avatarUrl}.`)
      })
      .catch(() => {
        console.warn(`Failed to load avatar image.`)
      })
  })
}
