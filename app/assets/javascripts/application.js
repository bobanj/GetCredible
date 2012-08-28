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
//= require givebrand.friendship
//= require givebrand.infinite_scroll
//= require givebrand.share_url

$(function (){
  $.giveBrand.showFlashMessages();
  $.giveBrand.ajaxPagination();
  $.giveBrand.init();
  $.giveBrand.friendship();
  $.giveBrand.updateTagCloud();
  $.giveBrand.inviteContact();
  $.giveBrand.importConnections();
  $.giveBrand.emailInvite();
  $.giveBrand.loginQtip();
  $.giveBrand.landingPageVideo();
  $.giveBrand.trackingPages();
  $.giveBrand.infiniteScroll();
  $.giveBrand.shareUrl();
});
