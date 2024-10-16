// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "@rails/request.js"
import "custom/companion"
import "chartkick"
import "Chart.bundle"
import Swal from 'sweetalert2';
import 'flowbite';

window.Swal = Swal;
