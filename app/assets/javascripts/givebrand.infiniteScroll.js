$.giveBrand.infiniteScroll = function () {
  if ($('#js_collection_list').length && $('.pagination').length > 0) {
    $('#js_footer').hide();
    $(window).scroll(function () {
      $('.pagination').hide();
      var url = $('.pagination .next_page').attr('href');
      if (url && ($(window).scrollTop() > $(document).height() - $(window).height() - 80)) {
        $('.pagination').text('Fetching...');
        $.getScript(url);
      }
    });

    $(window).scroll();
  }
};

$.giveBrand.scrollToTop = function () {
  var scrollBtn = $("#scroll_to_top");
  scrollBtn.hide();

  $(function () {
    $(window).scroll(function () {
      if ($(this).scrollTop() > 300) {
        scrollBtn.fadeIn();
      } else {
        scrollBtn.fadeOut();
      }
    });

    scrollBtn.click(function () {
      $('body,html').animate({
        scrollTop: 0
      }, 800);
      return false;
    });
  });
}
