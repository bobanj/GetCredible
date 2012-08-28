$.giveBrand.friendship = function () {
  $('.js-friendship-action').hover(function(){
    var button = $(this);
    var isFollowing = button.data('following');
    var buttonText = button.find('span');
    button.removeClass('unfollow follow following');
    if(isFollowing){
      buttonText.text('Unfollow');
      button.addClass('unfollow');
    } else {
      buttonText.text('Follow');
      button.addClass('follow');
    }
  }, function(){
    var button = $(this);
    var isFollowing = button.data('following');
    var buttonText = button.find('span');
    button.removeClass('unfollow follow following');
    if(isFollowing){
      buttonText.text('Following');
      button.addClass('following');
    } else {
      buttonText.text('Follow');
      button.addClass('follow');
    }
  });

  var changeFriendshipCounter = function (button, diff) {
    var counter;
    if (button.data('own-profile')) {
      counter = $('#js-following-count span');
    } else {
      counter = $('#js-followers-count span');
    }

    counter.text(parseInt(counter.text()) + diff);
  }

  $('.js-friendship-action').click(function(){
    var button = $(this);
    var isFollowing = button.data('following');
    var buttonText = button.find('span');
    button.removeClass('unfollow follow following');

    if (isFollowing) {
      button.data('following', false);
      buttonText.text('Follow');
      button.addClass('follow');

      $.post(button.data('unfollow-path'), { _method:'delete' }, function () {
        changeFriendshipCounter(button, -1);
      });
    } else {
      button.data('following', true);
      buttonText.text('Following');
      button.addClass('following');

      $.post(button.data('follow-path'), function () {
        changeFriendshipCounter(button, 1);
      });
    }
  });

  $('#profile_sidebar').delegate('.js-friendship-action', 'click', function () {
    if($(this).hasClass('disabled')){
      return false;
    } else {
      $(this).addClass('disabled');
    }
  });
};
