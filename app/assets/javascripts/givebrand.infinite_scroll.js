$.giveBrand.infiniteScroll = function () {
  if ($('#js_collection_list').length && $('.pagination').length > 0) {
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
