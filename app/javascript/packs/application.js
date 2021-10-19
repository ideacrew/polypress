// This file is automatically compiled by Webpack, along with any other files
// present in this directory. You're encouraged to place your actual application logic in
// a relevant structure within app/javascript and only use these pack files to reference
// that code so it'll be compiled.

import Rails from "rails-ujs";
import Turbolinks from "turbolinks";
import "channels";

// JS
import "../js/bootstrap_js_files";

// Images
const images = require.context("../images", true);
const imagePath = (name) => images(name, true);

import "jquery";
import "jquery-ui";
import "popper.js";

window.jQuery = $;
window.$ = $;
Rails.start();
Turbolinks.start();

// import "css/polypress";
// import "css/datatable_custom_filter";
// import "css/effective_datatable";
// import "datatables/datatable_custom_filter.js";
// import "bootstrap";
import "@fortawesome/fontawesome-free/css/all";