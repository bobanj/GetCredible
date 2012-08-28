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
};
