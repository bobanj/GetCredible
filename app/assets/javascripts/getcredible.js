 function InitializeAddNewTagFormSubmit()
 {
   $("#add-tag form").live("submit", function(){
   $("#tag-cloud").html("loading...");

 // This page is used just as a demo if you want to refresh cloud data html by rendering partial view.
 // In this demo load() method is used to simulate that.
 // If you want to see how it works use mozilla because chrome doesn't allow load() method for local files which we need for demo,
 // uncomment a raw below to reload tag and comment LoadTagsCloud() method below.
 // $('#tag-cloud').load('pages/page2.html');
 // Instead of load() use ajax which returns new html with refreshed data from database.

 // Ajax example:

 /* Example1
   var userId = "getUserWhoTagId";
   var userTagged = "getUserWhoIsTaggedId";
   var taggedWord = "newWord";
   $.ajax({
    url: 'urlWhichReturnsPartialViewHtmlForTagsCloud', (in this demo that is page2)
    type: "GET",
    data: { user1 : userId, user2 : userTagged, tag : taggedWord },
    success: function(data) {
       // replace existing tag-cloud html with the refreshed one
       $("#tag-cloud").html(data);
    });
   */
 /* Another way is to get new words_list from server with json.
 Example2
 Return json result as words_list with refreshed data from database to reload tags cloud
 Example for refreshed list:
 */

 var word_list1 = [
        {text: "lorem", customClass: "unvouche", weight: 13, title: "<span id='tag-cloud_tip_0'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
        {text: "ipsum", customClass: "unvouche", weight: 10.5, title: "<span id='tag-cloud_tip_1'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
        {text: "dolor", customClass: "tag", weight: 9.4, title: "<span id='tag-cloud_tip_2'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
        {text: "sit", customClass: "unvouche", weight: 8, title: "<span id='tag-cloud_tip_3'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
        {text: "amet", customClass: "unvouche", weight: 6.2, title: "<span id='tag-cloud_tip_4'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
        {text: "consectetur", customClass: "tag", weight: 5, title: "<span id='tag-cloud_tip_5'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
        {text: "adipiscing", customClass: "unvouche", weight: 5, title: "<span id='tag-cloud_tip_6'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
        {text: "elit", customClass: "unvouche", weight: 5, title: "<span id='tag-cloud_tip_7'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
        {text: "nam et", customClass: "unvouche", weight: 5, title: "<span id='tag-cloud_tip_8'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
        {text: "leo", customClass: "unvouche", weight: 4, title: "<span id='tag-cloud_tip_9'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
        {text: "sapien", customClass: "unvouche", weight: 4, title: "<span id='tag-cloud_tip_10'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
        {text: "pellentesque", customClass: "unvouche", weight: 3, title: "<span id='tag-cloud_tip_11'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
        {text: "habitant", customClass: "unvouche", weight: 3, title: "<span id='tag-cloud_tip_12'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
        {text: "morbi", customClass: "vouche", weight: 3, title: "<span id='tag-cloud_tip_13'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
        {text: "tristisque", customClass: "vouche", weight: 3, title: "<span id='tag-cloud_tip_14'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }}},           {text: "NEW TAG", customClass: "tag", weight: 3, title: "<span id='tag-cloud_tip_16'>13</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }}}
        ];
   LoadTagsCloud(word_list1);
   return false;
  });
}

function LoadTagsCloud(list)
{
  $("#tag-cloud").html("");
  $("#tag-cloud").jQCloud(list, {

    callback: function () {

    //w5
    $("#tag-cloud .w10, #tag-cloud .w9").tipsy({
      gravity: 'e',
      fade: true,
      html: true,
      delayOut: 50,
      title: function()
      {
        var original = this.getAttribute("original-title");
        var originalSpan = $(original).addClass("w5");
        var html = $('<div>').append($(originalSpan).clone()).remove().html();
        return html;
      }
      }).append('<span class="icon"></span>');

    //w4
    $("#tag-cloud .w8, #tag-cloud .w7").tipsy({
      gravity: 'e',
      fade: true,
      html: true,
      delayOut: 50,
      title: function()
      {
        var original = this.getAttribute("original-title");
        var originalSpan = $(original).addClass("w4");
        var html = $('<div>').append($(originalSpan).clone()).remove().html();
        return html;
      }
      }).append('<span class="icon"></span>');

    //w3
    $("#tag-cloud .w6, #tag-cloud .w5").tipsy({
      gravity: 'e',
      fade: true,
      html: true,
      delayOut: 50,
      title: function()
      {
        var original = this.getAttribute("original-title");
        var originalSpan = $(original).addClass("w3");
        var html = $('<div>').append($(originalSpan).clone()).remove().html();
        return html;
      }
      }).append('<span class="icon"></span>');

    //w2
    $("#tag-cloud .w4, #tag-cloud .w3").tipsy({
      gravity: 'e',
      fade: true,
      html: true,
      delayOut: 50,
      title: function()
      {
        var original = this.getAttribute("original-title");
        var originalSpan = $(original).addClass("w2");
        var html = $('<div>').append($(originalSpan).clone()).remove().html();
        return html;
      }
      }).append('<span class="icon"></span>');

    //w1
    $("#tag-cloud .w2, #tag-cloud .w1").tipsy({
      gravity: 'e',
      fade: true,
      html: true,
      delayOut: 50,
      title: function()
      {
        var original = this.getAttribute("original-title");
        var originalSpan = $(original).addClass("w1");
        var html = $('<div>').append($(originalSpan).clone()).remove().html();
        return html;
      }
      }).append('<span class="icon"></span>');
  }
  });
}

function InitializeOnClickVoucheUpOrDown(wordId)
{
  var tipId = wordId.replace("word", "tip");
  var voucheUp = $("#" + wordId).hasClass("unvouche");
  var voucheDown = $("#" + wordId).hasClass("vouche");
  var taged = $("#" + wordId).hasClass("tag");
  var word = $("#" + wordId).text();
  if(voucheUp)
  {
    var numOfVouches = $("#" + tipId).text();
    var numOfVouchesNew = parseInt(numOfVouches) + 1;
    var valNew = "<span id='" + tipId + "'>" + numOfVouchesNew + "</span>";
    $("#" + wordId).attr('original-title', valNew);
    $("#" + wordId).tipsy("hide");
    $("#" + wordId).tipsy("show");
    $("#" + wordId).tipsy({trigger: 'hover'});
    $("#" + wordId).removeClass("unvouche").addClass("vouche");
  }
  if(voucheDown)
  {
    var numOfVouches = $("#" + tipId).text();
    var numOfVouchesNew = parseInt(numOfVouches) - 1;
    var valNew = "<span id='" + tipId + "'>" + numOfVouchesNew + "</span>";
    $("#" + wordId).attr('original-title', valNew);
    $("#" + wordId).tipsy("hide");
    $("#" + wordId).tipsy("show");
    $("#" + wordId).tipsy({trigger: 'hover'});
    $("#" + wordId).removeClass("vouche").addClass("unvouche");
  }
}


var users_show = {
  run: function () {
    // This page is used just as a demo if you want to load cloud html by rendering partial view.
    // In this demo load() method is used to simulate ajax call which you use to call controller.
    // If you want to see how it works use mozilla because chrome doesn't allow load() method for local files which we need for this demo,
    // And uncomment a raw below to reload tag.
    // $('#tag-cloud').load('pages/page1.html');

      // Ajax example:

      /* Example1
      var userTagged = "getUserWhoIsTaggedId";
      $.ajax({
       url: 'urlWhichReturnsPartialViewForTagsCloud', (in this demo that is page1)
       type: "GET",
       data: { user1 : userId },
       success: function(data) {
          //fill tag-cloud html
          $("#tag-cloud").html(data);
       });
      */

    /* Another way is to get a words_list from server with json.

    Example2
    Return json result as words_list with refreshed data from database to reload tags cloud
    Example for refreshed list:

    */

    var tags_url = "/users/" + _user_id + "/tags";

    $("#add-tag form").submit(function (e) {
      e.preventDefault();
      var input = $('#tag_names');
      var tag_names  = input.val();

      if (tag_names.length) {
        input.val('');
        $.post(tags_url, {tag_names: tag_names}, function (data) {
          // TODO: display new tags received in data
        });
      }
    })

    // TODO: load tags on page load
    // $.get(tags_url, function () {
    //   alert(1)
    // });


     var word_list = [
           {text: "ddddd", customClass: "unvouche", weight: 13, title: "<span id='tag-cloud_tip_0'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
           {text: "ipsum", customClass: "unvouche", weight: 10.5, title: "<span id='tag-cloud_tip_1'>15</span>",handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
           {text: "dolor", customClass: "tag", weight: 9.4, title: "<span id='tag-cloud_tip_2'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
           {text: "sit", customClass: "unvouche", weight: 8, title: "<span id='tag-cloud_tip_3'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
           {text: "amet", customClass: "unvouche", weight: 6.2, title: "<span id='tag-cloud_tip_4'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
           {text: "consectetur", customClass: "tag", weight: 5, title: "<span id='tag-cloud_tip_5'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
           {text: "adipiscing", customClass: "unvouche", weight: 5, title: "<span id='tag-cloud_tip_6'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
           {text: "elit", customClass: "unvouche", weight: 5, title: "<span id='tag-cloud_tip_7'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
           {text: "nam et", customClass: "unvouche", weight: 5, title: "<span id='tag-cloud_tip_8'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
           {text: "leo", customClass: "unvouche", weight: 4, title: "<span id='tag-cloud_tip_9'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
           {text: "sapien", customClass: "unvouche", weight: 4, title: "<span id='tag-cloud_tip_10'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
           {text: "pellentesque", customClass: "unvouche", weight: 3, title: "<span id='tag-cloud_tip_11'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
           {text: "habitant", customClass: "unvouche", weight: 3, title: "<span id='tag-cloud_tip_12'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
           {text: "morbi", customClass: "vouche", weight: 3, title: "<span id='tag-cloud_tip_13'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }} },
           {text: "tristisque", customClass: "vouche", weight: 3, title: "<span id='tag-cloud_tip_14'>15</span>", handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }}}
    ];
    LoadTagsCloud(word_list);

    //initialize event for adding tag on form submit

    InitializeAddNewTagFormSubmit();
  }
}


$(function () {
  var id = $('body').attr("id");
  if (id) {
    controller_action = id;
    if (typeof(window[controller_action]) !== 'undefined' && typeof(window[controller_action]['run']) === 'function') {
      window[controller_action]['run']();
    }
  }
});

