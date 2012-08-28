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

