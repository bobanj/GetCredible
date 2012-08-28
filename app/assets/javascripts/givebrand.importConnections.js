function closeOmniauthPopup(){
  $.giveBrand.importingCheck();
  $.giveBrand.opener.close();
};

$.giveBrand.importingCheck = function(){
  $.get('/invite/state');
}

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
