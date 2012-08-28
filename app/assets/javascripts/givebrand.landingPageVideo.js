var landingVideoApi;

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
