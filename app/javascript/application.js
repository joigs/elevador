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

document.addEventListener('keydown', function(e) {
    if (e.target.type === 'number' && (e.key === 'ArrowUp' || e.key === 'ArrowDown')) {
        e.preventDefault();
    }
});
document.addEventListener("wheel", function (e) {
    const el = document.activeElement;
    if (el && el.type === "number" && el === e.target) {
        e.preventDefault();
        window.scrollBy({ top: e.deltaY, behavior: "auto" });
    }
}, { passive: false });