/* TODO: split into separate files */

Array.prototype.unique = function (){
  var o = {}, i, l = this.length, r = [];
  for (i = 0; i < l; i += 1) o[this[i]] = this[i];
  for (i in o) r.push(o[i]);
  return r;
};

$.notyConf = {
  layout:'topRight',
  timeout:2500,
  animateOpen:{opacity:'show'},
  animateClose:{opacity:'hide'}
};

$.giveBrand = {};
$.giveBrand.guideApi;
$.giveBrand.guideVideoId = 'UdijOhmTsUs';

$.giveBrand.displayNotification = function (type, text){
  noty({
    text:text,
    type:type,
    timeout:$.notyConf.timeout,
    layout:$.notyConf.layout,
    animateOpen:$.notyConf.animateOpen,
    animateClose:$.notyConf.animateClose,
    onClose:function (){
    }
  });
};

$.giveBrand.updatePageContent = function(data){
  $('#global-header').replaceWith(data.header);
  $('#tags').replaceWith(data.tag_cloud);
  if(data.show_guide){
    $("#guide").replaceWith(data.guide);
  }
}

$.giveBrand.initTokenInput = function (tagNamesTextField) {
  if (tagNamesTextField.length > 0){
    tagNamesTextField.tokenInput("/tags/search", {
      method:'POST',
      queryParam:'term',
      propertyToSearch:'term',
      tokenValue:'term',
      crossDomain:false,
      theme:"facebook",
      hintText:'e.g. web design, leadership (comma separated)',
      minChars:2
    });
  }
};

$.giveBrand.init = function (){
  $.giveBrand.tagCloudPath = null;
  $.giveBrand.tagCloudQtipApi = null;
  $.giveBrand.currentQtipTarget = null;
  $.giveBrand.tagCloudLoader = $("#tag-cloud-loader");
  $.giveBrand.tagCloud = $("#tag-cloud");

  var tagNamesTextField = $("#tag_names");
  $.giveBrand.initTokenInput(tagNamesTextField);

  $("#add-tag form").submit(function (e){
    e.preventDefault();
    var form = $(this);
    if(form.hasClass('disabled')){
      return false;
    }
    form.addClass('disabled');
    var tagNames = $("#tag_names");
    if (tagNames.length > 0){
      tagNames = tagNames.val();
    } else{
      tagNames = ''
    }
    if (tagNames != '' && $.giveBrand.tagCloud.length > 0){
      var addTag = function (){
        if ($.giveBrand.tagCloud.data('can-tag')){
          $.post($.giveBrand.tagCloud.data('tag-cloud-path'),
              form.serialize(), function (data){
                tagNamesTextField.tokenInput("clear");
                $.giveBrand.displayNotification('success', 'You have tagged ' + $.giveBrand.tagCloud.data('user').name + ' with ' + tagNames);
                $.giveBrand.renderTagCloud(data, function(){
                  form.removeClass('disabled');
                });
                mixpanel.track("Tag");
              });
        } else{
          $.giveBrand.displayNotification('error', 'You cannot vote for yourself')
        }
      }

      if ($.giveBrand.tagCloud.data('logged-in')){
        addTag();
      } else{
        $("#tag_names_after_login").val($("#tag_names").val());
        $.giveBrand.loginQtipApi.set('content.text', $('#login_dialog'));
        $.giveBrand.loginQtipApi.show();
      }
    } else {
      form.removeClass('disabled');
    }
    return false;
  });

  $('#login_dialog #user_sign_in .btn').click(function (e){
    e.preventDefault();
    var form = $(this).parents('form');

    var params = form.serialize() + '&user_id=' + $.giveBrand.tagCloud.data('user-name');
    $.post("/users/sign_in.json", params, function (data){
      if (data.success){
        $.giveBrand.updatePageContent(data);
        $.giveBrand.init();
        $.giveBrand.updateTagCloud(function (){
          $.giveBrand.actionsAfterLogin(data);
          $.giveBrand.loginQtipApi.hide();
          mixpanel.track("Activity Page");
        });
      } else{
        $.each(data.errors, function (index, text){
          $.giveBrand.displayNotification('error', text);
        })
      }
    });
  });

  $('#login_dialog #user_sign_up .btn').click(function (e){
    e.preventDefault();
    var form = $(this).parents('form');

    var params = form.serialize() + '&user_id=' + $.giveBrand.tagCloud.data('user-name');
    $.post("/users.json", params, function (data){
      if (data.success){
        $.giveBrand.updatePageContent(data);
        $.giveBrand.init();
        $.giveBrand.updateTagCloud(function (){
          $.giveBrand.actionsAfterLogin(data);
          $.giveBrand.loginQtipApi.hide();
          mixpanel.track("Activity Page");
        });
      } else{
        $.each(data.errors, function (index, text){
          $.giveBrand.displayNotification('error', text);
        })
      }
    });
  });
}

$.giveBrand.vote = function (word){
  var word = $(word);
  var voteToggle;
  if (typeof(this.tagCloudPath) == 'string'){
    voteToggle = word.hasClass('vouch') ? '/unvote.json' : '/vote.json';
    if (this.tagCloud.data('logged-in') == false){
      $("#word_id_after_login").val('#' + word.attr('id'));
      $("#tag_names_after_login").val($("#tag_names").val());
      $.giveBrand.loginQtipApi.set('content.text', $('#login_dialog'));
      $.giveBrand.loginQtipApi.show();
      return;
    }

    if (this.tagCloud.data('can-vote')){
      if(voteToggle == '/unvote.json'){
        noty({
          text:'Are you sure you want to unvouch for ' + word.text() + '?',
          layout:'center',
          type:'alert',
          buttons:[
            {type:'btn primary medium', text:'Ok', click:function (){
              $.giveBrand.submitVote(word, voteToggle);
            } },
            {type:'btn primary medium red', text:'Cancel', click:function (){

            } }
          ],
          closable:false,
          timeout:false
        });

      } else {
        $.giveBrand.submitVote(word, voteToggle);
      }

    } else{
      if (!this.tagCloud.data('can-delete')){
        $.giveBrand.displayNotification('alert', 'You can not vouch for yourself')
      }
    }
  } else{
    $.giveBrand.displayNotification('error', 'You are not authorized for this action')
  }
};

$.giveBrand.submitVote = function(word, voteToggle){
  $.post(this.tagCloudPath + '/' + word.data('user-tag-id') + voteToggle, function (data){
    if (data.status == 'ok'){
      var user = $.giveBrand.tagCloud.data('user');
      var voters = $.giveBrand.voterImages(data.voters);
      word.data('score', data.score);
      word.data('user-tag-id', data.id);
      word.data('tagged', data.tagged);
      word.data('rank', data.rank);
      word.data('total', data.total);
      word.data('voters', voters.join(''));
      word.data('voters_count', data.voters_count);
      word.removeClass('vouch unvouch');
      word.addClass(data.voted ? "vouch " : "unvouch");
      $.giveBrand.updateQtipContentData(word);
      $.giveBrand.tagCloudQtipApi.set('content.text', word.data('qtip-content'));
      if (data.voters_count === null){
        if ($.giveBrand.tagCloudQtipApi){
          $.giveBrand.tagCloudQtipApi.hide();
        }
        $.giveBrand.updateTagCloud(function (){
        });
      } else{
        if (word.hasClass('vouch')){
          $.giveBrand.displayNotification('success', 'You have vouched for ' + word.text());
        } else{
          mixpanel.track("Tag");
          $.giveBrand.displayNotification('success', 'You have removed vouch for ' + word.text());
        }
      }
      $('.ui-tooltip-content .tag-vote').unbind('click').click(function (){
        $.giveBrand.vote($.giveBrand.currentQtipTarget);
        return false;
      });
    }
  });
}

$.giveBrand.voterImages = function (voters){
  var votersImages = [];
  $.each(voters, function (index, voter){
    votersImages.push('<a rel="nofollow" href="' + voter.url +'"><img src=' + voter.avatar + ' title=' + voter.name + ' alt=' + voter.name + '/></a>')
  });

  return votersImages;
};

$.giveBrand.getWordCustomClass = function (userTag){
  var customClass = "skill ";
  customClass += this.tagCloud.data('can-delete') ? 'remove ' : '';
  if ($.giveBrand.tagCloud.data('can-vote') && !this.tagCloud.data('can-delete')){
    customClass += userTag.voted ? "vouch " : "unvouch ";
  }
  return customClass;
}

$.giveBrand.createWordList = function (data, distributionOptions){
  var wordList = [];
  var writeEndorsementSelect = $("#write_endorsement_user_tag_id");
  writeEndorsementSelect.html('<option value=""></option>');
  if (data.length == 0){
    writeEndorsementSelect.trigger("liszt:updated");
    $("#endorsements").addClass('hide');
    return wordList;
  } else {
    $("#endorsements").removeClass('hide');
  }
  $.each(data, function (i, userTag){
    writeEndorsementSelect.append(
        $('<option></option>').val(userTag.id).html(userTag.name)
    );
    var voters = $.giveBrand.voterImages(userTag.voters);
    wordList.push({
      text:userTag.name,
      html:{
        //title:userTag.name,
        class:$.giveBrand.getWordCustomClass(userTag)
      },
      weight:parseInt((userTag.score - distributionOptions.min) / distributionOptions.divisor),
      dataAttributes:{ score:userTag.score, 'user-tag-id':userTag.id,
        rank:userTag.rank, total:userTag.total, tagged:userTag.tagged,
        voters:voters.join(''), voters_count:userTag.voters_count}
      //handlers:{click:function (){
      //  $.giveBrand.vote(this);
      //}}
    });
  });
  writeEndorsementSelect.trigger("liszt:updated");
  return wordList;
}

$.giveBrand.distributionOptions = function (data){
  if (data.length === 0){
    return {min:1, parts:1, divisor:1};
  }

  var min = data[0].score;
  var max = data[0].score;
  var votes = [];
  var parts;
  $.each(data, function (i, userTag){
    votes.push(userTag.score)
    if (userTag.score > max){
      max = userTag.score;
    }
    if (userTag.score < min){
      min = userTag.score;
    }
  });
  var uniqVotes = votes.unique().length;
  if (uniqVotes < 5){
    parts = uniqVotes;
  } else{
    parts = 5;
  }
  var divisor = (max - min) / parts;
  return {min:min, parts:parts, divisor:divisor};
};

$.giveBrand.updateQtipContentData = function (word){
  var rank = word.data('rank') ? '#' + word.data('rank') : 'N/A';
  var vouchUnvouch = word.hasClass('vouch') ? 'Remove' : 'Vouch';
  var vouchUnvouchClass = word.hasClass('vouch') ? 'btn primary red tiny' : 'btn primary green tiny';
  var qtipContent = '<div class="tag-wrap">' +
      '<div class="tag-score">' +
      '<p class="tag-title">score</p>' +
      '<p class="tag-big">' + word.data('score') + '</p>' +
      '<p class="tag-place">' + rank + ' out of ' + word.data('total') + '</p>' +
      '</div>' +
      '<div class="tag-votes">' +
      '<p>' + word.data('voters_count') +
      (word.data('voters_count') == 1 ? ' person' : ' people') +
      '  vouched for ' + word.text() + '</p>' +
      '<p>' + word.data('voters') + '</p>' +
      '</div>';
  if ($.giveBrand.tagCloud.data('can-vote')){
    //qtipContent = qtipContent + '<div class="tag-action"><a href="#" class="tag-vote button ' + vouchUnvouchClass + '">' + vouchUnvouch + '</a><a href="#" class="js-tag-endorse button btn primary white tiny">Endorse</a></div>'
    qtipContent = qtipContent + '<div class="tag-action"><a href="#" class="tag-vote button ' + vouchUnvouchClass + '">' + vouchUnvouch + '</a></div>'
  }
  qtipContent = qtipContent + '</div>';
  word.data('qtip-content', qtipContent);
};

$.giveBrand.disableCloudEdit = function (){
  $('#tag-cloud').data("can-delete", false);
  $('#edit_tag_cloud').removeClass('edit').text('Edit');
};

$.giveBrand.enableCloudEdit = function (){
  $('#tag-cloud').data("can-delete", true);
  $('#edit_tag_cloud').addClass('edit').text('Done');
};
//$.giveBrand.endorsementForm = $('#write_endorsement_form');
$.giveBrand.renderTagCloud = function (data, tagCloudCallback){
  var distributionOptions = $.giveBrand.distributionOptions(data);
  var wordList = $.giveBrand.createWordList(data, distributionOptions);
  var letterCount = 0;
  $.each(data, function (i, userTag){
    letterCount += userTag.name.length;
  });

  if (wordList.length > 0){
    $('#js_no_tags').hide();
    $('#edit_tag_cloud').removeClass('hidden');
  } else{
    $('#js_no_tags').show();
    $('#edit_tag_cloud').addClass('hidden');
    $.giveBrand.disableCloudEdit();
  }
  $.giveBrand.tagCloudLoader.show('fast');
  $.giveBrand.tagCloud.html('');
  var growHeight = (letterCount / 20) * 65;
  if(growHeight < 290){
    growHeight = 290;
  }
  $.giveBrand.tagCloud.css('height', growHeight + 'px');
  $.giveBrand.tagCloud.jQCloud(wordList, {
    width:680,
    height:growHeight,
    nofollow:true,
    parts:distributionOptions.parts,
    delayedMode:true,
    afterCloudRender:function (){
      $.giveBrand.tagCloudLoader.hide('fast');
      var words = $("#tag-cloud .skill");
      words.each(function (){
        var word = $(this);
        $.giveBrand.updateQtipContentData(word);
        if (word.hasClass('remove')){
          word.append('<span class="icon"></span>');
        }
      });
      $.giveBrand.tagCloudQtipApi = $('<div />').qtip(
          {
            content:' ', // Can use any content here :)
            position:{
              target:'event', // Use the triggering element as the positioning target
              effect:false, // Disable default 'slide' positioning animation
              my:'bottom center',
              at:'top center'
            },
            show:{
              target:words
            },
            hide:{
              //target: words
              event:'unfocus'
            },
            events:{
              show:function (event, api){
                // Update the content of the tooltip on each show
                $.giveBrand.currentQtipTarget = $(event.originalEvent.target);
                if ($.giveBrand.currentQtipTarget.length){
                  $('#token-input-tag_names').blur();
                  api.set('content.text', $.giveBrand.currentQtipTarget.data('qtip-content'));
                  $('.ui-tooltip-content .tag-vote').unbind('click').click(function (){
                    $.giveBrand.vote($.giveBrand.currentQtipTarget);
                    return false;
                  });
                  // Behaviour for endorsement in tooltip
                  //var tooltip = api.elements.tooltip;
                  //var endorsementButton = tooltip.find('.js-tag-endorse');
                  //if(endorsementButton.length){
                    //endorsementButton.unbind('click');
                    //endorsementButton.click(function(e){
                      //e.preventDefault();
                      //api.set('content.text',$.giveBrand.endorsementForm );
                      //tooltip = api.elements.tooltip;
                      //var endorsementDescription = tooltip.find("#endorsement_description");
                      //if(endorsementDescription.length){
                        //endorsementDescription.limit('300', tooltip.find("#write_endorsement_word_counter"));
                      //}
                      //return false
                    //});
                  //}
                }
              },
              hide:function (event, api){
                // Update the content of the tooltip on each show
                var target = $(event.originalEvent.target);
                if (target.hasClass('word') && $.giveBrand.currentQtipTarget.attr('id') == target.attr('id')){
                  return false;
                }
              }
            },
            style:{
              classes:'ui-tooltip-light ui-tooltip-rounded ui-tooltip-tag-cloud'
            }

          }).qtip('api');
      //Delegate fails
      $("#tag-cloud .remove .icon").click(function (){
        var word = $(this).parent();
        noty({
          text:'Are you sure you want to delete this tag?',
          layout:'center',
          type:'alert',
          buttons:[
            {type:'btn primary medium', text:'Ok', click:function (){
              if ($.giveBrand.tagCloud.data('can-delete')){
                $.post($.giveBrand.tagCloudPath + '/' + word.data('user-tag-id'), { _method:'delete' }, function (data){
                  $.giveBrand.renderTagCloud(data, function(){

                  });
                });
              }
            } },
            {type:'btn primary medium red', text:'Cancel', click:function (){

            } }
          ],
          closable:false,
          timeout:false
        });
      });

      // vote callback after login via modal window
      if ($.isFunction(tagCloudCallback)){
        tagCloudCallback();
      }
    }});
}

$.giveBrand.updateTagCloud = function (tagCloudCallback){
  if (this.tagCloud.length > 0){
    this.tagCloudPath = this.tagCloud.data('tag-cloud-path');
    $.getJSON(this.tagCloud.data('tag-cloud-path'), function (data){
      $.giveBrand.renderTagCloud(data, tagCloudCallback);
    });
  }
};
$.giveBrand.showFlashMessages = function (){
  var flashMessage = $("#flash-message");
  if (flashMessage.length > 0){
    var messageType = flashMessage.data('type');
    if (messageType == 'error'){
      $.giveBrand.displayNotification('error', flashMessage.text());
    }
    if (messageType == 'alert'){
      $.giveBrand.displayNotification('alert', flashMessage.text());
    }
    if (messageType == 'notice'){
      $.giveBrand.displayNotification('success', flashMessage.text());
    }
  }
}

$.giveBrand.actionsAfterLogin = function (data){
  var tagNamesAfterLogin = $("#tag_names_after_login");
  if (tagNamesAfterLogin.val() != ''){
    $("#tag_names").val(tagNamesAfterLogin.val());
    tagNamesAfterLogin.val('');
    $("#add-tag form").submit();
  }
  var wordIdAfterLogin = $('#word_id_after_login');
  if (wordIdAfterLogin.val() != ''){
    $.giveBrand.vote(wordIdAfterLogin.val());
    wordIdAfterLogin.val('');
  }
  if (data.show_guide){
    if($.isFunction($.giveBrand.guideApi.show)){
      $.giveBrand.guideApi.show();
    }
  }
  if(!data.own_profile){
    $("#write_endorsement_form").removeClass('hide');
  }
}

$('body').delegate('.js-remote', 'click', function (event){
  $.ajax({
    url:$(this).attr('href'),
    success:function (data){
      $('#main').html(data);
      $.giveBrand.ajaxPagination();
      $.giveBrand.showFlashMessages();
    },
    error:function (){
      $.giveBrand.displayNotification('error', 'Something Went Wrong');
    }
  });
  event.preventDefault();
  return false;
});

$.giveBrand.emailPreviewQtipApi = $('<div />').qtip({
    content:{
        id:'email_preview',
        text: ' ',
        title:{
            text: ' ',
            button:true
        }
    },
    position:{
        my:'center', // ...at the center of the viewport
        at:'center',
        target: $(window)
    },
    show:{
        ready: false,
        solo: true, // ...and hide all other tooltips...
        event: 'click',
        modal:{
            on:true,
            blur:false,
            escape:true
        }
    },
    hide:false,
    style: { classes:'ui-tooltip-light ui-tooltip-shadow ui-tooltip-rounded ui-tooltip-contact email' }
}).click(function (event) {
    event.preventDefault();
    return false;
}).qtip('api');

$('#content').delegate('#preview_email_sample', 'click', function (e) {
    e.preventDefault();
    $.giveBrand.emailPreviewQtipApi.set('content.text', $('#email_preview'));
    $.giveBrand.emailPreviewQtipApi.show();
});

$('#edit_tag_cloud').click(function (e){
  e.preventDefault();
  if ($(this).hasClass('edit')){
    $.giveBrand.disableCloudEdit();
  } else{
    $.giveBrand.enableCloudEdit();
  }
  $.giveBrand.updateTagCloud();
});

var shortBioTextarea = $('#user_short_bio');
if (shortBioTextarea.length > 0){
  shortBioTextarea.limit('200', $("#short_bio_word_counter"));
}


$("#user_edit_avatar_file").change(function (){
  $("#user_edit_avatar_loading").show();
  $("#user_edit_avatar_form").submit();
  return false;
});


$.giveBrand.showFlashMessages();
