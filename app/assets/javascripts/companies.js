$(function() {
  'use strict';

  $('body').on('ajax:success', '.companies_pagination', function (e, data) {
    $('#companies_list').html(data);
    // In case there is tooltip(s) in rendered element:
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('body').on('ajax:complete', '#companies_search', function (e, response) {

    if (response.status !== 200) {
      alert('Something went wrong - please reload page and try again.');
      return;
    }

    var data = JSON.parse(response.responseText);

    $('#companies_list').html(data.list_html);
    $('#companies_map').html(data.map_html);
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('body').on('ajax:success', '.events_pagination', function (e, data) {
    $('#company-events').html(data);
    // In case there is tooltip(s) in rendered element:
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('#brandingStatusForm').on('ajax:success', function (e, data) {
    $('#company-branding-status').html(data);
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('.dinkurs-fetch-events').on('ajax:success', function (e, data) {
    $('#company-events').html(data);
    $('[data-toggle="tooltip"]').tooltip();
  });

  $('#editBrandingStatusSubmit').click(function() {
    $('#edit-branding-modal').modal('hide');
  });

  $('#companyCreateForm').on('ajax:success', function (e, data) {
    var ele = $('#' + data.id);

    if (data.status === 'errors') {
      ele.html(data.value);
    } else {

      $('#company-create-modal').on('hidden.bs.modal', function() {
        ele.val( function( index, val ) {
          return (val.length > 0 ? val + ', ' + data.value : data.value);
        });
      }).modal('hide');

      $('#company-create-errors').html('');
    }
  });
});
