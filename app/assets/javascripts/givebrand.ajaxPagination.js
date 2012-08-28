$.giveBrand.ajaxPagination = function (){
  var pagination = $('#main .pagination');
  if (pagination.length > 0){
    pagination.find('a').addClass('js-remote');
  }
}
