// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require easing
//= require mousewheel
//= require jquery-ui
//= require jquery_ujs
//= require jqcloud
//= require jquery.noty
//= require jquery.tokeninput
//= require jquery.qtip
//= require jquery-progress-bubbles
//= require jquery.remotipart
//= require jquery.limit-1.2.source
//= require chosen.jquery
//= require jquery.embedly.min
//= require givebrand.js
//= require givebrand.guide.js
//= require givebrand.endorsements
//= require givebrand.friendship
//= require givebrand.importConnections
//= require givebrand.invite
//= require givebrand.loginQtip
//= require givebrand.landingPageVideo
//= require givebrand.trackingPages
//= require givebrand.infiniteScroll
//= require givebrand.shareUrl
//= require givebrand.ajaxPagination

$(function (){
  $.giveBrand.init();
  $.giveBrand.guide();
  $.giveBrand.endorsements();
  $.giveBrand.friendship();
  $.giveBrand.updateTagCloud(); // in givebrand.js
  $.giveBrand.importConnections();
  $.giveBrand.invite();
  $.giveBrand.loginQtip();
  $.giveBrand.landingPageVideo();
  $.giveBrand.trackingPages();
  $.giveBrand.infiniteScroll();
  $.giveBrand.shareUrl();
  $.giveBrand.ajaxPagination();
});
