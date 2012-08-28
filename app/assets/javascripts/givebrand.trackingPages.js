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
