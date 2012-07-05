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
//= require jquery.simplemodal
//= require jquery.tokeninput
//= require jquery.qtip
//= require jquery-progress-bubbles
//= require jquery.remotipart
//= require jquery.limit-1.2.source

Array.prototype.unique = function (){
  var o = {}, i, l = this.length, r = [];
  for (i = 0; i < l; i += 1) o[this[i]] = this[i];
  for (i in o) r.push(o[i]);
  return r;
};

var guideVideoApi;
// called when YouTube Api is loaded

function onYouTubePlayerAPIReady(){
  guideVideoApi = new YT.Player('guide_video', {
    playerVars:{
      autoplay:0,
      enablejsapi:1,
      origin:document.location.host
    },
    origin:document.location.host,
    height:240,
    width:370,
    videoId:$.getCredible.guideVideoId,
    events:{
      'onReady':function (e){
        // Store the player in the API
        guideVideoApi = e.target;
      }
    }
  });
}

$(function (){
  $.notyConf = {
    layout:'topRight',
    timeout:2500,
    animateOpen:{opacity:'show'},
    animateClose:{opacity:'hide'}
  };

  $.getCredible = {};
  $.getCredible.guide = {
    isUpdating: false
  }
  $.getCredible.guideApi;
  $.getCredible.guideVideoId = 'He_PWsJqsVY';

  $.getCredible.displayNotification = function (type, text){
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

  $.getCredible.updatePageContent = function(data){
    $('#global-header').replaceWith(data.header);
    $('#tags').replaceWith(data.tag_cloud);
    $('#endorsements').replaceWith(data.endorsements);
    if(data.show_guide){
      $("#main").prepend(data.guide);
    }
  }

  $.getCredible.init = function (){
    $.getCredible.tagCloudPath = null;
    $.getCredible.tagCloudQtipApi = null;
    $.getCredible.currentQtipTarget = null;
    $.getCredible.tagCloudLoader = $("#tag-cloud-loader");
    $.getCredible.tagCloud = $("#tag-cloud");

    var tagNamesTextField = $("#tag_names");
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

    $("#add-tag form").submit(function (e){
      e.preventDefault();
      var form = $(this);
      var tagNames = $("#tag_names");
      if (tagNames.length > 0){
        tagNames = tagNames.val();
      } else{
        tagNames = ''
      }
      if (tagNames != '' && $.getCredible.tagCloud.length > 0){
        var addTag = function (){
          if ($.getCredible.tagCloud.data('can-tag')){
            $.post($.getCredible.tagCloud.data('tag-cloud-path'),
                form.serialize(), function (data){
                  tagNamesTextField.tokenInput("clear");
                  $.getCredible.displayNotification('success', 'You have tagged ' + $.getCredible.tagCloud.data('user').name + ' with ' + tagNames);
                  $.getCredible.renderTagCloud(data);
                  mixpanel.track("Tagged user from profile");
                });
          } else{
            $.getCredible.displayNotification('error', 'You cannot vote for yourself')
          }
        }

        if ($.getCredible.tagCloud.data('logged-in')){
          addTag();
        } else{
          $("#tag_names_after_login").val($("#tag_names").val());
          $.getCredible.loginQtipApi.set('content.text', $('#login_dialog'));
          $.getCredible.loginQtipApi.show();
        }
      }
      return false;
    });

    $('#login_dialog #user_sign_in .btn').click(function (e){
      e.preventDefault();
      var form = $(this).parents('form');

      var params = form.serialize() + '&user_id=' + $.getCredible.tagCloud.data('user-name');
      $.post("/users/sign_in.json", params, function (data){
        if (data.success){
          $.getCredible.updatePageContent(data);
          $.getCredible.init();
          $.getCredible.updateTagCloud(function (){
            $.getCredible.actionsAfterLogin(data);
            $.getCredible.loginQtipApi.hide();
            mixpanel.track("Sign in from modal");
          });
        } else{
          $.each(data.errors, function (index, text){
            $.getCredible.displayNotification('error', text);
          })
        }
      });
    });

    $('#login_dialog #user_sign_up .btn').click(function (e){
      e.preventDefault();
      var form = $(this).parents('form');

      var params = form.serialize() + '&user_id=' + $.getCredible.tagCloud.data('user-name');
      $.post("/users.json", params, function (data){
        if (data.success){
          $.getCredible.updatePageContent(data);
          $.getCredible.init();
          $.getCredible.updateTagCloud(function (){
            $.getCredible.actionsAfterLogin(data);
            $.getCredible.loginQtipApi.hide();
            mixpanel.track("Sign up from modal");
          });
        } else{
          $.each(data.errors, function (index, text){
            $.getCredible.displayNotification('error', text);
          })
        }
      });
    });
    $.getCredible.guide();
    $.getCredible.endorsements();
  }

  $.getCredible.vote = function (word){
    var word = $(word);
    var voteToggle;
    if (typeof(this.tagCloudPath) == 'string'){
      voteToggle = word.hasClass('vouch') ? '/unvote.json' : '/vote.json';
      if (this.tagCloud.data('logged-in') == false){
        $("#word_id_after_login").val('#' + word.attr('id'));
        $("#tag_names_after_login").val($("#tag_names").val());
        $.getCredible.loginQtipApi.set('content.text', $('#login_dialog'));
        $.getCredible.loginQtipApi.show();
        return;
      }

      if (this.tagCloud.data('can-vote')){
        $.post(this.tagCloudPath + '/' + word.data('user-tag-id') + voteToggle, function (data){
          if (data.status == 'ok'){
            var user = $.getCredible.tagCloud.data('user');
            var voters = $.getCredible.voterImages(data.voters);
            word.data('score', data.score);
            word.data('user-tag-id', data.id);
            word.data('tagged', data.tagged);
            word.data('rank', data.rank);
            word.data('total', data.total);
            word.data('voters', voters.join(''));
            word.data('voters_count', data.voters_count);
            word.removeClass('vouch unvouch');
            word.addClass(data.voted ? "vouch " : "unvouch");
            $.getCredible.updateQtipContentData(word);
            $.getCredible.tagCloudQtipApi.set('content.text', word.data('qtip-content'));
            if (data.voters_count === null){
              if ($.getCredible.tagCloudQtipApi){
                $.getCredible.tagCloudQtipApi.hide($('.word'));
              }
              $.getCredible.updateTagCloud(function (){
              });
            } else{
              if (word.hasClass('vouch')){
                $.getCredible.displayNotification('success', 'You have vouched for ' + word.text());
                mixpanel.track("User vouch remove");
              } else{
                $.getCredible.displayNotification('success', 'You have removed vouch for ' + word.text());
                mixpanel.track("User vouched");
              }
            }
            $('.tag-vote').click(function (){
              $.getCredible.vote($.getCredible.currentQtipTarget);
              return false;
            });
          }
        });
      } else{
        if (!this.tagCloud.data('can-delete')){
          $.getCredible.displayNotification('alert', 'You can not vouch for yourself')
        }
      }
    } else{
      $.getCredible.displayNotification('error', 'You are not authorized for this action')
    }
  };

  $.getCredible.voterImages = function (voters){
    var votersImages = [];
    $.each(voters, function (index, voter){
      votersImages.push('<img src=' + voter.avatar + ' title=' + voter.name + ' alt=' + voter.name + '/>')
    });

    return votersImages;
  };

  $.getCredible.getWordCustomClass = function (userTag){
    var customClass = "word ";
    customClass += this.tagCloud.data('can-delete') ? 'remove ' : '';
    if ($.getCredible.tagCloud.data('can-vote') && !this.tagCloud.data('can-delete')){
      customClass += userTag.voted ? "vouch " : "unvouch ";
    }
    return customClass;
  }

  $.getCredible.createWordList = function (data, distributionOptions){
    var wordList = [];

    if (data.length == 0){
      return wordList;
    }
    $.each(data, function (i, userTag){
      var voters = $.getCredible.voterImages(userTag.voters);
      wordList.push({
        text:userTag.name,
        html:{
          //title:userTag.name,
          class:$.getCredible.getWordCustomClass(userTag)
        },
        weight:parseInt((userTag.score - distributionOptions.min) / distributionOptions.divisor),
        dataAttributes:{ score:userTag.score, 'user-tag-id':userTag.id,
          rank:userTag.rank, total:userTag.total, tagged:userTag.tagged,
          voters:voters.join(''), voters_count:userTag.voters_count}
        //handlers:{click:function (){
        //  $.getCredible.vote(this);
        //}}
      });
    });
    return wordList;
  }

  $.getCredible.distributionOptions = function (data){
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

  $.getCredible.updateQtipContentData = function (word){
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
    if ($.getCredible.tagCloud.data('can-vote')){
      qtipContent = qtipContent + '<div class="tag-action"><a href="#" class="tag-vote button ' + vouchUnvouchClass + '">' + vouchUnvouch + '</a></div>'
    }
    qtipContent = qtipContent + '</div>';
    word.data('qtip-content', qtipContent);
  };

  $.getCredible.disableCloudEdit = function (){
    $('#tag-cloud').data("can-delete", false);
    $('#edit_tag_cloud').removeClass('edit').text('Edit');
  };

  $.getCredible.enableCloudEdit = function (){
    $('#tag-cloud').data("can-delete", true);
    $('#edit_tag_cloud').addClass('edit').text('Done');
  };

  $.getCredible.renderTagCloud = function (data, tagCloudCallback){
    var distributionOptions = $.getCredible.distributionOptions(data);
    var wordList = $.getCredible.createWordList(data, distributionOptions);
    if (wordList.length > 0){
      $('#js_no_tags').hide();
      $('#edit_tag_cloud').removeClass('hidden');
    } else{
      $('#js_no_tags').show();
      $('#edit_tag_cloud').addClass('hidden');
      $.getCredible.disableCloudEdit();
    }
    $.getCredible.tagCloudLoader.show('fast');
    $.getCredible.tagCloud.html('');
    var growHeight = 250 + (wordList.length * 3);
    $.getCredible.tagCloud.css('height', growHeight + 'px');
    $.getCredible.tagCloud.jQCloud(wordList, {
      width:700,
      height:growHeight,
      nofollow:true,
      parts:distributionOptions.parts,
      delayedMode:true,
      afterCloudRender:function (){
        $.getCredible.tagCloudLoader.hide('fast');
        var words = $("#tag-cloud .word");
        words.each(function (){
          var word = $(this);
          $.getCredible.updateQtipContentData(word);
          if (word.hasClass('remove')){
            word.append('<span class="icon"></span>');
          }
        });
        $.getCredible.tagCloudQtipApi = $('<div />').qtip(
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
                  $.getCredible.currentQtipTarget = $(event.originalEvent.target);
                  if ($.getCredible.currentQtipTarget.length){
                    api.set('content.text', $.getCredible.currentQtipTarget.data('qtip-content'));
                    $('.tag-vote').click(function (){
                      $.getCredible.vote($.getCredible.currentQtipTarget);
                      return false;
                    });
                  }
                },
                hide:function (event, api){
                  // Update the content of the tooltip on each show
                  var target = $(event.originalEvent.target);
                  if (target.hasClass('word') && $.getCredible.currentQtipTarget.attr('id') == target.attr('id')){
                    return false;
                  }
                }
              },
              style:{
                classes:'ui-tooltip-light ui-tooltip-rounded ui-tooltip-qtip'
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
                if ($.getCredible.tagCloud.data('can-delete')){
                  $.post($.getCredible.tagCloudPath + '/' + word.data('user-tag-id'), { _method:'delete' }, function (data){
                    $.getCredible.renderTagCloud(data, function(){
                      mixpanel.track("User delete tag");
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

  $.getCredible.updateTagCloud = function (tagCloudCallback){
    if (this.tagCloud.length > 0){
      this.tagCloudPath = this.tagCloud.data('tag-cloud-path');
      $.getJSON(this.tagCloud.data('tag-cloud-path'), function (data){
        $.getCredible.renderTagCloud(data, tagCloudCallback);
      });
    }
  };

  $.getCredible.ajaxPagination = function (){
    var pagination = $('#main .pagination');
    if (pagination.length > 0){
      pagination.find('a').addClass('js-remote');
    }
  }
  $.getCredible.showFlashMessages = function (){
    var flashMessage = $("#flash-message");
    if (flashMessage.length > 0){
      var messageType = flashMessage.data('type');
      if (messageType == 'error'){
        $.getCredible.displayNotification('error', flashMessage.text());
      }
      if (messageType == 'alert'){
        $.getCredible.displayNotification('alert', flashMessage.text());
      }
      if (messageType == 'notice'){
        $.getCredible.displayNotification('success', flashMessage.text());
      }
    }
  }

  $.getCredible.actionsAfterLogin = function (data){
    var tagNamesAfterLogin = $("#tag_names_after_login");
    if (tagNamesAfterLogin.val() != ''){
      $("#tag_names").val(tagNamesAfterLogin.val());
      tagNamesAfterLogin.val('');
      $("#add-tag form").submit();
    }
    var wordIdAfterLogin = $('#word_id_after_login');
    if (wordIdAfterLogin.val() != ''){
      $.getCredible.vote(wordIdAfterLogin.val());
      wordIdAfterLogin.val('');
    }
    var endorseAfterLogin = $("#endorse_after_login");
    if(endorseAfterLogin.val() === 'true'){
      endorseAfterLogin.val('');
      $("#write_endorsement_form").slideDown();
    }
    if(endorseAfterLogin.val() != ''){
      if(!data.own_profile){
        $('#endorse_' + endorseAfterLogin.val() + '_link').click();
      } else {
        $.getCredible.displayNotification('error', "You can't endorse yourself");
      }
      endorseAfterLogin.val('');
    }
    if (data.show_guide){
      if($.isFunction($.getCredible.guideApi.show)){
        $.getCredible.guideApi.show();
      }
    }
  }

  $('body').delegate('.js-remote', 'click', function (event){
    $.ajax({
      url:$(this).attr('href'),
      success:function (data){
        $('#main').html(data);
        $.getCredible.ajaxPagination();
        $.getCredible.showFlashMessages();
      },
      error:function (){
        $.getCredible.displayNotification('error', 'Something Went Wrong');
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

  $.getCredible.guide = function (){
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

    $.getCredible.guideApi = $('#steps').qtip(
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
                if($.getCredible.guide.isUpdating){
                  e.preventDefault();
                  return false;
                } else {
                  $.getCredible.guide.isUpdating = true;
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
                if ($.getCredible.guide.isUpdating){
                  return false;
                } else{
                  $.getCredible.guide.isUpdating = true;
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
                          $.getCredible.displayNotification('success', 'You have tagged yourself with ' + step2TagNames.val());
                          if ($.getCredible.tagCloud.length > 0){
                            $.getCredible.renderTagCloud(data);
                          }
                          skipStep2();
                          mixpanel.track("User tagged himself");
                        });
                  } else{
                    skipStep2();
                    //$.getCredible.displayNotification('error', 'Please add tags');
                  }
                }
                return false;
              });

              $("#guide_close").click(function (e){
                e.preventDefault();
                api.hide();
                mixpanel.track("Guide close");
                return false;
              });
              mixpanel.track("Guide render");
            }
          }
        }).qtip('api');

    $("#show_guide").click(function (e){
      e.preventDefault();
      $.getCredible.guideApi.show();
      mixpanel.track("Guide show");
      return false;
    });

    var bubbleContainer = $("#bubbles_container");
    if (bubbleContainer.length > 0 && bubbleContainer.data('show_guide')){
      $.getCredible.guideApi.show();
      mixpanel.track("Guide show");
    }
  }

  $.getCredible.twitterInvite = function (){
    $.getCredible.twitterQtipApi = $('<div />').qtip({
      content:{
        id:'twitter_invite_modal',
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
      style:{ classes:'ui-tooltip-light ui-tooltip-shadow ui-tooltip-rounded ui-tooltip-twitter' }
    }).click(
        function (event){
          event.preventDefault();
          return false;
        }).qtip('api');

    $('#content').delegate('.twitter_contact', 'click', function (){
      var contact = $(this);
      var twitterUsername = contact.data('screen_name');
      var twitterId = contact.data('twitter_id');
      $('#twitter_message_twitter_id').val(twitterId);
      $('#twitter_message_screen_name').val(twitterUsername);
      $("#js-twitter-invite-header").text("Invite and brand @" + twitterUsername);
      $.getCredible.twitterQtipApi.set('content.text', $('#twitter_invite'));
      $.getCredible.twitterQtipApi.show();
    });

    $('#js-twitter-invitation-form').live('submit', function (e) {
      $(this).find('.loading').show();
    });
  };


  $.getCredible.emailInvite = function () {
    $.getCredible.emailQtipApi = $('<div />').qtip({
        content:{
            id:'twitter_invite_modal',
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
        style: { classes:'ui-tooltip-light ui-tooltip-shadow ui-tooltip-rounded ui-tooltip-twitter' }
    }).click(function (event) {
        event.preventDefault();
        return false;
    }).qtip('api');

    $('#content').delegate('.email_button', 'click', function (e) {
        e.preventDefault();
        $.getCredible.emailQtipApi.set('content.text', $('#email_invite'));
        $.getCredible.emailQtipApi.show();
    });

    $('#js-email-invitation-form').live('submit', function (e) {
      $(this).find('.loading').show();
      mixpanel.track("Email invitation send");
    });
  };


  $.getCredible.loginQtip = function (){
    $.getCredible.loginQtipApi = $('<div />').qtip({
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
      $.getCredible.disableCloudEdit();
    } else{
      $.getCredible.enableCloudEdit();
    }
    $.getCredible.updateTagCloud();
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

  $.getCredible.endorsements = function (){
    $("#endorsements").on("click", ".js-endorse-tag", function (e){
      e.preventDefault();
      var userTagId = $(this).data('user_tag_id');
      if (!$.getCredible.tagCloud.data('logged-in')){
        $("#endorse_after_login").val(userTagId);
        $.getCredible.loginQtipApi.set('content.text', $('#login_dialog'));
        $.getCredible.loginQtipApi.show();
        return false;
      }
      var endorseContainer = $("#endorse_" + userTagId + "_container");
      var endorsementForm = $(".js-endorsement-form-new");
      if (endorseContainer.length > 0 && endorsementForm.length > 0){
        //endorsementForm.find('#endorsement_description').val('');
        endorsementForm.show();
        endorseContainer.find(".tag-endorse").before(endorsementForm);
        endorsementForm.find("#endorsement_user_tag_id").val(userTagId);
        endorsementForm.find("#user_tag_id").val(userTagId);
        var endorsementTextarea = endorsementForm.find("#endorsement_description");
        if (endorsementTextarea.length > 0){
          endorsementTextarea.limit('300', $("#endorsement_word_counter"));
        }
        endorsementTextarea.focus();
      }
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
          self.text("Hide all endorsements");
          endorsements.slideDown(800, function(){
            $(this).removeClass('hide');
          });
        } else{
          self.text("Show all endorsements");
          endorsements.slideUp(800, function(){
            $(this).addClass('hide');
          });
        }
      }
      return false;
    });
    $("#endorsements").on("click", ".js-endorsement-delete", function (e){
      e.preventDefault();
      var self = $(this);
      noty({
        text:'Are you sure you want to delete this endorsement?',
        layout:'center',
        type:'alert',
        buttons:[
          {type:'btn primary medium', text:'Ok', click:function (){
            $.post(self.attr('href'), { _method:'delete' }, function (data){
              if (data.status == 'ok'){
                self.parent().parent().remove();
                var endorsementsList = $('#endorsements_' + data.user_tag_id + '_list');
                var endorseContainer = $('#endorse_' + data.user_tag_id + '_container');
                var numEndorsements = endorseContainer.find('span.score');
                numEndorsements.html(parseInt(numEndorsements.text()) - 1);
                if (endorsementsList.length > 0 && endorsementsList.children().length == 0){
                  endorseContainer.find('.js-endorsements-toggle').addClass('hide');
                }
                mixpanel.track("Endorsement destroy");
              } else{
                $.getCredible.displayNotification('error', 'You can only delete your own endorsements');
              }
            });
          } },
          {type:'btn primary medium red', text:'Cancel', click:function (){

          } }
        ],
        closable:false,
        timeout:false
      });
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
    $("#endorsements").on("click","#write_endorsement_button", function(e){
      e.preventDefault();
      if (!$.getCredible.tagCloud.data('logged-in')){
        $("#endorse_after_login").val('true');
        $.getCredible.loginQtipApi.set('content.text', $('#login_dialog'));
        $.getCredible.loginQtipApi.show();
      } else {
        $("#write_endorsement_form").slideToggle();
      }
      return false;
    })
    $("#endorsements").on("click","#write_endorsement_cancel", function(e){
      e.preventDefault();
      $("#write_endorsement_form").slideUp();
      $("#write_endorsement_description_error").text('');
      $("#write_endorsement_tag_error").text('');
    });

    if($("#write_endorsement_description").length){
      $("#write_endorsement_description").limit('300', $("#write_endorsement_word_counter"));
    }

    $("#endorsements").on("submit", "#write_endorsement_form", function (e){
      var endorsementDescription = $("#write_endorsement_description");
      var err = false;
      if(endorsementDescription.val() == ''){
        err = true;
        $("#write_endorsement_description_error").text("Please insert endorsement");
      } else {
        $("#write_endorsement_description_error").text('');
      }
      var endorsementTag = $("#write_endorsement_tag");
      if(endorsementTag.val() == ''){
        err = true
        $("#write_endorsement_tag_error").text("Please insert the name of the tag you want to endorse");
      } else {
        $("#write_endorsement_tag_error").text('');
      }
      if(err){
        e.preventDefault();
        return false;
      }
      $(this).find('.loader').removeClass('hide');
    });

  }

  $.getCredible.trackingPages = function(){
    var pageAction = $('body').attr('id');
    // Landing Page
    switch(pageAction){
      case 'home_index':
        mixpanel.track("Landing page");
        $("#landing_sign_in").click(function(){
          mixpanel.track("Landing page sign in");
        });
        $("#landing_sign_up_top").click(function(){
          mixpanel.track("Landing page sign up top");
        });
        $("#landing_sign_up_bottom").click(function(){
          mixpanel.track("Landing page sign up bottom");
        });
      break;
      case 'users_registrations_create':
        mixpanel.track("Sign up page");
        break;
      case 'users_sessions_new':
        mixpanel.track("Sign in page");
        break;
      case 'devise_passwords_new':
        mixpanel.track("Forgot password page");
        break;
      case 'users_index':
        mixpanel.track("Search results page");
        break;
      case 'activities_show':
        mixpanel.track("Home page");
        break;
      case 'users_following':
        mixpanel.track("User following page");
        break;
      case 'users_followers':
        mixpanel.track("User followers page");
        break;
      case 'users_show':
        mixpanel.track("User profile page");
        break;
      case 'users_registrations_edit':
        mixpanel.track("User edit profile page");
        break;
      case 'invite_index':
        mixpanel.track("User invite page");
        break;
      default:
        mixpanel.track(pageAction);
        break;
    }
  }

  $.getCredible.showFlashMessages();
  $.getCredible.ajaxPagination();
  $.getCredible.init();
  $.getCredible.updateTagCloud();
  $.getCredible.twitterInvite();
  $.getCredible.emailInvite();
  $.getCredible.loginQtip();
  $.getCredible.trackingPages();
});
