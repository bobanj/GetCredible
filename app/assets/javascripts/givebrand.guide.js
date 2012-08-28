var guideVideoApi;

// called when YouTube Api is loaded
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

$.giveBrand.guide = {
  isUpdating: false
}

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

