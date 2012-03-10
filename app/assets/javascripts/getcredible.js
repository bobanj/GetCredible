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

function InitializeOnClickVoucheUpOrDown(wordId) {
  var tipId = wordId.replace("word", "tip");
  var voucheUp = $("#" + wordId).hasClass("unvouche");
  var voucheDown = $("#" + wordId).hasClass("vouche");
  var taged = $("#" + wordId).hasClass("tag");
  var word = $("#" + wordId).text();

  if (voucheUp) {
    var numOfVouches = $("#" + tipId).text();
    var numOfVouchesNew = parseInt(numOfVouches) + 1;
    var valNew = "<span id='" + tipId + "'>" + numOfVouchesNew + "</span>";
    $("#" + wordId).attr('original-title', valNew);
    $("#" + wordId).tipsy("hide");
    $("#" + wordId).tipsy("show");
    $("#" + wordId).tipsy({trigger: 'hover'});
    $("#" + wordId).removeClass("unvouche").addClass("vouche");
  }

  if (voucheDown) {
    var numOfVouches = $("#" + tipId).text();
    var numOfVouchesNew = parseInt(numOfVouches) - 1;
    var valNew = "<span id='" + tipId + "'>" + numOfVouchesNew + "</span>";
    $("#" + wordId).attr('original-title', valNew);
    $("#" + wordId).tipsy("hide");
    $("#" + wordId).tipsy("show");
    $("#" + wordId).tipsy({trigger: 'hover'});
    $("#" + wordId).removeClass("vouche").addClass("unvouche");
  }
};

var extractVotes = function (tags) {
  var votes = [];
  for (var i = 0; i < tags.length; i++) {
    votes.push(tags[i].votes);
  }
  return votes;
};

var findMin = function (votes) {
  min = 0;
  for (var i = 0; i < votes.length; i++) {
    vote = votes[i];
    if (vote < min) {
      min = vote;
    }
  }
  return min;
};

var findMax = function (votes) {
  max = 0;
  for (var i = 0; i < votes.length; i++) {
    vote = votes[i];
    if (vote > max) {
      max = vote;
    }
  }
  return max;
};

var drawTags = function (tags, min, max, divisor) {
  var parts     = 10;
  var votes     = extractVotes(tags);
  var min       = findMin(votes);
  var max       = findMax(votes);
  var divisor   = (max - min) / parts;

  var word_list = [];

  for (var i = 0; i < tags.length; i++) {
    var tag = tags[i];
    var weight = parseInt((tag.votes - min) / divisor)

    word_list.push({
      text: tag.name,
      customClass: "unvouche",
      // customClass: "tag",
      // customClass: "vouche",
      weight: weight,
      title: "<span id='tag-cloud_tip_" + i + "'>" + tag.votes + "</span>",
      handlers: {click: function() { InitializeOnClickVoucheUpOrDown($(this).attr("id")); }}
    })
  }

  LoadTagsCloud(word_list);
};


var users_show = {
  run: function () {
    var userTagsUrl = "/users/" + _user_id + "/tags";

    $.get(userTagsUrl, function (data) {
      drawTags(data);
    });

    $("#add-tag form").live("submit", function (e) {
      e.preventDefault();

      var input = $('#tag_names');
      var tag_names  = input.val();

      if (tag_names.length) {
        input.val('');
        $("#tag-cloud").html("loading...");
        $.post(userTagsUrl, {tag_names: tag_names}, function (data) {
          drawTags(data);
        });
      }
    });
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
