$(function() {
  'use strict';

  $('#business_categories tbody tr:not(.accordion)').hide();

  $("tr.business_category.accordion").click(function(){
    $(this).next('tr').toggle();
  });
});
