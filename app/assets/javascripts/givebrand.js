Array.prototype.unique = function (){
  var o = {}, i, l = this.length, r = [];
  for (i = 0; i < l; i += 1) o[this[i]] = this[i];
  for (i in o) r.push(o[i]);
  return r;
};

var guideVideoApi, landingVideoApi;
// called when YouTube Api is loaded

function closeOmniauthPopup(){
  $.giveBrand.importingCheck();
  $.giveBrand.opener.close();
};

function onYouTubePlayerAPIReady(){
  guideVideoApi = new YT.Player('guide_video', {
    playerVars:{
      autoplay:0,
      enablejsapi:1,
      showinfo: 0,
      origin:document.location.host
    },
    origin:document.location.host,
    height:240,
    width:370,
    videoId:$.giveBrand.guideVideoId,
    events:{
      'onReady':function (e){
        // Store the player in the API
        guideVideoApi = e.target;
      }
    }
  });
}

$.notyConf = {
  layout:'topRight',
  timeout:2500,
  animateOpen:{opacity:'show'},
  animateClose:{opacity:'hide'}
};

$.giveBrand = {};
$.giveBrand.guide = {
  isUpdating: false
}
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
  $.giveBrand.guide();
  $.giveBrand.endorsements();
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

$.giveBrand.ajaxPagination = function (){
  var pagination = $('#main .pagination');
  if (pagination.length > 0){
    pagination.find('a').addClass('js-remote');
  }
}
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

var invitationExistingTagNames = $('#invite_tag_names');
var prePopulateInvitationTags = [];
if (invitationExistingTagNames.length > 0 && invitationExistingTagNames.val() != ''){
  invitationExistingTagNames = invitationExistingTagNames.val().split(',');
  $.each(invitationExistingTagNames, function (index, tagName){
    prePopulateInvitationTags.push({term:tagName});
  });
}
$('#invite_tag_names').tokenInput("/tags/search", {
  method:'POST',
  queryParam:'term',
  propertyToSearch:'term',
  tokenValue:'term',
  crossDomain:false,
  theme:"facebook",
  hintText:'e.g. web design, leadership (comma separated)',
  minChars:2,
  prePopulate:prePopulateInvitationTags
});

$.giveBrand.guide = function (){
  $('#bubbles').progressBubbles({
        bubbles:[
          {'title':'1'},
          {'title':'2'},
          {'title':'3'}
        ]
      }
  );

  $("#guide_video_link").click(function (e){
    e.preventDefault();
    $("#step_2_form").hide('fast');
    $("#guide_video_container").show('fast');
    if ($.isFunction(guideVideoApi.playVideo)){
      guideVideoApi.playVideo();
    }
    return false;
  });

  $("#guide_video_back").click(function (e){
    e.preventDefault();
    if($.isFunction(guideVideoApi.stopVideo)){
      guideVideoApi.stopVideo();
    }
    if($.isFunction(guideVideoApi.clearVideo)){
      guideVideoApi.clearVideo();
    }
    $("#guide_video_container").hide('fast');
    $("#step_2_form").show('fast');
    return false;
  });

  $.giveBrand.guideApi = $('#steps').qtip(
      {
        id:'guide_qtip', // Since we're only creating one modal, give it an ID so we can style it
        content:{
          text:$('#bubbles_container'),
          title:false
        },
        position:{
          my:'center', // ...at the center of the viewport
          at:'center',
          target:$(window)
        },
        show:{
          ready:false,
          event:'click', // Show it on click...
          //solo: true, // ...and hide all other tooltips...
          modal:{
            on:true,
            blur:false,
            escape:true
          }
        },
        hide:false,
        style:{
          classes:'ui-tooltip-light ui-tooltip-shadow ui-tooltip-rounded ui-tooltip-guide'
        },
        events:{
          visible: function(){
            if($(".bubble.active .bubble-title").text() == '1'){
              $("#step_1_form #user_full_name").focus();
            }
          },
          render:function (event, api){
            // Step 1 is handled with update.js.erb
            // focus on FullName when guide is shown
            $("#step_1_form").submit(function(e){
              if($.giveBrand.guide.isUpdating){
                e.preventDefault();
                return false;
              } else {
                $.giveBrand.guide.isUpdating = true;
                mixpanel.track("Guide next step 1");
              }
            });

            $("#user_avatar_file").change(function (){
              $("#user_avatar_guide_form .loading").show();
              $("#user_avatar_guide_form").submit();
              return false;
            });

            // Step 2 Video
            $("#prev_step_2").click(function (){
              $("#step_2").hide('fast', function (){
                $('#bubbles').progressBubbles('regress');
                $("#step_1").show('fast');
              });
              mixpanel.track("Guide previous step 2");
              return false;
            });

            $("#next_step_2").click(function (){
              $("#step_2 form").submit();
              mixpanel.track("Guide next step 2");
              return false;
            });

            $("#prev_step_3").click(function (){
              $("#step_3").hide('fast', function (){
                $('#bubbles').progressBubbles('regress');
                $("#step_2").show('fast');
              });
              mixpanel.track("Guide previous step 3");
              return false;
            });

            $("#next_step_3").click(function (){
              api.hide();
              mixpanel.track("Guide next step 3");
              return false;
            });

            $("#step_2 form").submit(function (e){
              e.preventDefault();
              if ($.giveBrand.guide.isUpdating){
                return false;
              } else{
                $.giveBrand.guide.isUpdating = true;
                var form = $(this);
                var tagOne = $("#tag_1");
                var tagTwo = $("#tag_2");
                var tagThree = $("#tag_3");
                var step2TagNames = $("#step_2_tags");
                var skipStep2 = function (){
                  $("#step_2").hide('fast', function (){
                    $('#bubbles').progressBubbles('progress');
                    $("#step_3").show('fast');
                  });
                }
                if (tagOne.val() != '' || tagTwo.val() != '' || tagThree.val() != ''){
                  var tagNames = [];
                  if (tagOne.val() != ''){
                    tagNames.push(tagOne.val());
                  }
                  if (tagOne.val() != ''){
                    tagNames.push(tagTwo.val());
                  }
                  if (tagOne.val() != ''){
                    tagNames.push(tagThree.val());
                  }
                  step2TagNames.val(tagNames.join(','));
                  $.post(form.data('tags-path'),
                      form.serialize(), function (data){
                        //$.giveBrand.displayNotification('success', 'You have tagged yourself successfully');
                        if ($.giveBrand.tagCloud.length > 0){
                          $.giveBrand.renderTagCloud(data);
                        }
                        $.giveBrand.guide.isUpdating = false;
                        skipStep2();
                        mixpanel.track("Tag");
                      });
                } else{
                  skipStep2();
                  $.giveBrand.guide.isUpdating = false;
                  //$.giveBrand.displayNotification('error', 'Please add tags');
                }
              }
              return false;
            });

            $("#guide_close").click(function (e){
              e.preventDefault();
              api.hide();
              if($.isFunction(guideVideoApi.stopVideo)){
                guideVideoApi.stopVideo();
              }
              return false;
            });
            mixpanel.track("Guide show");
          }
        }
      }).qtip('api');

  $("#show_guide").click(function (e){
    e.preventDefault();
    $.giveBrand.guideApi.show();
    mixpanel.track("Guide show");
    return false;
  });

  var bubbleContainer = $("#bubbles_container");
  if (bubbleContainer.length > 0 && bubbleContainer.data('show_guide')){
    $.giveBrand.guideApi.show();
  }
}

$.giveBrand.importingCheck = function(){
  $.get('/invite/state');
}

$.giveBrand.inviteContact = function (){
  $.giveBrand.invitationMessageQtipApi = $('<div />').qtip({
    content:{
      id:'invitation_message_modal',
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
    style:{ classes:'ui-tooltip-light ui-tooltip-shadow ui-tooltip-rounded ui-tooltip-contact' }
  }).click(
      function (event){
        event.preventDefault();
        return false;
    }).qtip('api');

  $('#main').delegate('.js-contact-invite', 'click', function (e) {
    e.preventDefault();
    var contact = $(this).data('contact');
    var contactName;
    if (contact.provider === 'twitter') {
      contactName = contact.name + " @" + contact.screen_name;
    } else {
      contactName = contact.name;
    }
    $('#invitation_message_uid').val(contact.uid);
    $('#invitation_message_provider').val(contact.provider);
    $('#invitation_message_name').val(contact.name);
    $('#invitation_message_screen_name').val(contact.screen_name);
    $("#js-invitation-message-header").html("Invite <strong>" + contactName + "</strong>");
    $("#js-invitation-message-note").html("Suggest three tags you think describe " + contact.name + ".");

    $.giveBrand.invitationMessageQtipApi.set('content.text', $('#invitation_message_invite'));
    $.giveBrand.invitationMessageQtipApi.show();
  });

  $('#js-invitation-message-form').live('submit', function (e) {
    $(this).find('.loading').show();
  });

  if ($('a.importing').length){
    $.giveBrand.importingCheck();
  }
};

$.giveBrand.importConnections = function(){
  $('a.js-import-popup').die('click').click(function(e){
    var omniauthPath = $(this).data('omniauth');
    if(typeof(omniauthPath) == 'string'){
      e.preventDefault();
      $.giveBrand.opener = window.open(omniauthPath, $(this).data('provider').toString(), 'menubar=no,width=790,height=360,toolbar=no');
      return false;
    }
  });
}
$.giveBrand.emailInvite = function () {
  $("#js-email-invite").click(function () {
    $("#email_invite").slideToggle();
  })

  $('#js-email-invitation-form').live('submit', function (e) {
    mixpanel.track("Invitation");
    $(this).find('.loading').show();
  });
};

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

$.giveBrand.loginQtip = function (){
  $.giveBrand.loginQtipApi = $('<div />').qtip({
    content:{
      id:'simplemodal-container', //TODO fix the id
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
    style:{ classes:'ui-tooltip-light ui-tooltip-shadow ui-tooltip-rounded ui-tooltip-login' }
  }).click(
      function (event){
        event.preventDefault();
        return false;
      }).qtip('api');
};

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

$.giveBrand.endorsements = function (){
  $("#endorsements").on("click", ".js-endorse-tag", function (e){
    e.preventDefault();
    var userTagId = $(this).data('user_tag_id');
    var endorseContainer = $("#endorse_" + userTagId + "_container");
    var endorsementForm = $("#js-endorsement-form");
    endorsementForm.show();
    endorseContainer.find(".tag-endorse").before(endorsementForm);
    endorsementForm.find("#endorsement_user_tag_id").val(userTagId);
    var endorsementTextarea = endorsementForm.find("#endorsement_description");
    endorsementTextarea.limit('300', $("#endorsement_word_counter"));
    endorsementTextarea.focus();
  });

  $("#endorsements").on("submit", ".js-endorsement-form", function (e){
    $(this).find('.loader').removeClass('hide');
  });

  $("#endorsements").on("click", ".js-endorsements-toggle", function (e){
    e.preventDefault();
    var self = $(this);
    var userTagId = $(this).data('user_tag_id');
    var endorsements = $('#endorsements_' + userTagId + '_list');
    if (endorsements.length > 0){
      if (endorsements.hasClass('hide')){
        self.text("Minimize");
        endorsements.slideDown(800, function(){
          $(this).removeClass('hide');
        });
      } else{
        self.text("Expand");
        endorsements.slideUp(800, function(){
          $(this).addClass('hide');
        });
      }
    }
    return false;
  });


  $("#endorsements").on("click", ".js-cancel-endorsement", function (e){
    e.preventDefault();

    var form = $(this).parents('form');
    var endorsement = form.parent('li').find('> .js_endorsement');
    if (endorsement.length > 0) {
      endorsement.show();
      form.remove();
    } else {
      form.hide();
    }
  })
//    $("#endorsements").on("click","#write_endorsement_button, #write_endorsement_link", function(e){
//      e.preventDefault();
//      if (!$.giveBrand.tagCloud.data('logged-in')){
//        $("#endorse_after_login").val('true');
//        $.giveBrand.loginQtipApi.set('content.text', $('#login_dialog'));
//        $.giveBrand.loginQtipApi.show();
//      } else {
//        $("#write_endorsement_form").slideToggle();
//      }
//      return false;
//    })

  $("#endorsements").on("click","#write_endorsement_cancel", function(e){
    e.preventDefault();
    $("#write_endorsement_form").slideUp();
    $("#write_endorsement_description_error").text('');
    $("#write_endorsement_tag_error").text('');
  });

  if($("#write_endorsement_description").length){
    $("#write_endorsement_description").limit('300', $("#write_endorsement_word_counter"));
  }

  if($("#write_endorsement_user_tag_id").length){
    $("#write_endorsement_user_tag_id").chosen();
  }

  $("#endorsements").on("submit", "#write_endorsement_form", function (e){
    $(this).find('.loader').removeClass('hide');
  });

}

$.giveBrand.trackingPages = function(){
  var pageAction = $('body').attr('id');
  // Landing Page
  switch(pageAction){
    case 'home_index':
      mixpanel.track("Landing page");
      $("#user_sign_in").submit(function(){
        mixpanel.track("Activity Page");
      });
      $("#landing_sign_up_top").submit(function(){
        mixpanel.track("Landing page");
      });
      $("#landing_sign_up_bottom").submit(function(){
        mixpanel.track("Landing page");
      });
    break;
    case 'users_registrations_create':
      mixpanel.track("Landing page");
      break;
    case 'users_sessions_new':
      mixpanel.track("Landing page");
      break;
    case 'devise_passwords_new':
      break;
    case 'users_index':
      mixpanel.track("Search results page");
      break;
    case 'activities_show':
      mixpanel.track("Activity Page");
      break;
    case 'users_following':
      //mixpanel.track("User following page");
      break;
    case 'users_followers':
      //mixpanel.track("User followers page");
      break;
    case 'users_show':
      //mixpanel.track("Profile page");
      break;
    case 'users_registrations_edit':
      //mixpanel.track("Profile page");
      break;
    case 'invite_index':
      //mixpanel.track("User invite page");
      break;
    case 'users_invitations_edit':
      mixpanel.track("User accepted invitation");
      break;
    default:
      //mixpanel.track(pageAction);
      break;
  }
}

$.giveBrand.landingPageVideo = function () {
      $('.video').qtip({
    content:{
      text: $('<div />', { id: 'landing-video' }),
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
      },
      effect: function() {
        var style = this[0].style;
        style.display = 'none';
        setTimeout(function() { style.display = 'block'; }, 1);
      }
    },
    hide: false,
    events:{
      render: function (event, api){
        landingVideoApi = new YT.Player('landing-video', {
          playerVars:{
            autoplay:1,
            enablejsapi:1,
            showinfo: 0,
            wmode: "opaque",
            origin:document.location.host
          },
          origin:document.location.host,
          height: 390,
          width: 640,
          videoId:$.giveBrand.guideVideoId,
          events:{
            'onReady':function (e){
              // Store the player in the API
              api.player = e.target;
            }
          }
        });
      },
      show: function(event, api){
        // Pause the video when tooltip is hidden
        if(api.player && $.isFunction(api.player.playVideo)) {
          api.player.playVideo();
        }
      },
      hide: function(event, api){
        // Pause the video when tooltip is hidden
        if(api.player && $.isFunction(api.player.stopVideo)) {
          api.player.stopVideo();
        }
      }
    },
    style:{
      classes:'ui-tooltip-light ui-tooltip-landing-video'
    }
  });

};
