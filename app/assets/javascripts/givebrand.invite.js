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

$.giveBrand.emailByInvite = function () {
  $("#js-email-invite").click(function () {
    $("#email_invite").slideToggle();
  })

  $('#js-email-invitation-form').live('submit', function (e) {
    mixpanel.track("Invitation");
    $(this).find('.loading').show();
  });
};

$.giveBrand.invite = function (){
  $.giveBrand.inviteContact(); // in givebrand.js
  $.giveBrand.emailByInvite(); // in givebrand.js
};
