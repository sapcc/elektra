module.exports = {
  // use juno tailwindcss as default
  presets: [
    require("@cloudoperators/juno-ui-components/build/lib/tailwind.config"),
  ],
  prefix: "tw-", // important, do not change
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

  darkMode: "class",
}
