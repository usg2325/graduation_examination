module.exports = {
  content: [
    './app/views/**/*.html.erb',
    './app/helpers/**/*.rb',
    './app/assets/stylesheets/**/*.css',
    './app/javascript/**/*.js'
  ],
  theme: {
    extend: {
      fontFamily: {
        kiwi: ['Kiwi Maru', 'serif'],
        kosugi: ['Kosugi Maru', 'sans-serif'],
        logo: ['Archivo Black', 'sans-serif']
      }
    }
  },
  plugins: [
    require('daisyui')
  ],
  daisyui: {
    themes: ["synthwave"],
  },
}
