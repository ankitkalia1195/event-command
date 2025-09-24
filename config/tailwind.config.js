/** @type {import('tailwindcss').Config} */
module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  darkMode: 'class',
  theme: {
    extend: {
      colors: {
        'omise-teal': '#00D4AA',
        'omise-teal-dark': '#00B894',
        'omise-teal-light': '#00E5C7',
      }
    },
  },
  plugins: [],
}
