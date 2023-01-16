module.exports = {
  // use juno tailwindcss as default
  presets: [require("juno-ui-components/tailwind.config")],
  prefix: "", // important, do not change
  content: [
    "./plugins/**/*.{js,jsx,html,haml}",
    "./app/javascript/**/*.{js,jsx,haml}",
    "./app/views/**/*.{haml,html}",
  ],

  theme: {
    extend: {},
  },
  corePlugins: {
    preflight: false,
  },
  plugins: [],
}
