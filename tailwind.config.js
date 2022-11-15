// opacity helper to make custom colors work with opacity
function withOpacity(variableName) {
  return ({ opacityVariable, opacityValue }) => {
    if (opacityValue !== undefined) {
      return `rgba(var(${variableName}), ${opacityValue})`
    }
    if (opacityVariable !== undefined) {
      return `rgba(var(${variableName}), var(${opacityVariable}, 1))`
    }
    return `rgb(var(${variableName}))`
  }
}

module.exports = {
  presets: [require("juno-ui-components/tailwind.config")],
  prefix: "", // important, do not change
  content: [
    "./plugins/**/*.{js,html,haml}",
    "./app/javascript/**/*.{js,haml}",
    "./app/views/**/*.haml",
  ],
  theme: {
    extend: {},
  },
  corePlugins: {
    preflight: false,
  },
  plugins: [],
}
