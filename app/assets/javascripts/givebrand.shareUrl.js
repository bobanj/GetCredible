$.giveBrand.shareQtipApi = $('<div />').qtip({
  content:{
    id:'share_modal',
    text:' ',
    title:{
      text:' ',
      button:true
    }
  },
  position:{
    my:'center', // ...at the center of the viewport
    at:'center',
    target:$(window)
  },
  show:{
    ready:false,
    solo:true, // ...and hide all other tooltips...
    event:'click',
    modal:{
      on:true,
      blur:false,
      escape:true
    }
  },
  hide:false,
  style:{ classes:'ui-tooltip-light ui-tooltip-shadow ui-tooltip-rounded ui-tooltip-share-url' }
}).click(function (event) {
  event.preventDefault();
  return false;
}).qtip('api');


$.giveBrand.shareUrlInit = function(){
  var typingTimer;
  var doneTypingInterval = 200;

  $('#link_url').focus();
  $('#link_url').keyup(function(){
    clearTimeout(typingTimer);
    if ($('#link_url').val) {
      typingTimer = setTimeout(getUrlInfo, doneTypingInterval);
    }
  });

  function getUrlInfo () {
    var url = $.trim($('#link_url').val());

    if (url.length === 0) {
      return;
    }

    if (!url.match(/^https?:\/\//)) {
      url = "http://" + url;
    }

    $.embedly(url, { key: EMBEDLY_KEY }, function (oembed, dict) {
      $('#js-url-details').removeClass('hidden');
      $('#link_url').val(oembed.url);
      $('#link_title').val(oembed.title);
      $('#link_description').val(oembed.description);
      $('#link_thumbnail_url').val(oembed.thumbnail_url);
      if (oembed.thumbnail_url) {
        $('#js-thumbnail-url').html('<img src=' + oembed.thumbnail_url + '>');
      }
    });
  }
};

$.giveBrand.resetShareForm = function(){
  $('#js-url-details').addClass('hidden');
  $('#link_url').val('');
  $('#link_title').val('');
  $('#link_description').val('');
  $('#link_thumbnail_url').val('');
  $('#js-thumbnail-url').html('');
};

$.giveBrand.shareUrl = function(){
  $.giveBrand.initTokenInput($("#link_tag_names"));

  $('#js_share_btn').click(function () {

    $.giveBrand.resetShareForm()

    $.giveBrand.shareQtipApi.set('content.text', $('#share_link'));
    $.giveBrand.shareQtipApi.show();
    $.giveBrand.shareUrlInit()
  });
}
