# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "@hotwired--stimulus.js" # @3.2.2
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "slim-select" # @2.8.1
pin "tom-select" # @2.3.1
pin "stimulus-rails-nested-form" # @4.1.0
pin_all_from "app/javascript/custom", under: "custom"
pin "flowbite", to: "https://cdn.jsdelivr.net/npm/flowbite@2.5.2/dist/flowbite.turbo.min.js"
pin "@popperjs/core", to: "@popperjs--core.js" # @2.11.8
pin "flowbite-datepicker" # @1.3.0
pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"
pin "sweetalert2" # @11.14.0
pin "flatpickr", to: "https://cdn.jsdelivr.net/npm/flatpickr"
pin "flatpickr/es", to: "https://cdn.jsdelivr.net/npm/flatpickr/dist/l10n/es.js"
