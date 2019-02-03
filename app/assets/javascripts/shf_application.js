$(function() {
  'use strict';

  // Check to see if any file delivery radio button is selected -
  // if so, remove "disable" from submit button, hide explain text
  // if not, set callback function, on button change, to perform above actions

  var button_checked = false;
  var radio_buttons = $('input:radio[name="shf_application[file_delivery_method_id]"]');

  radio_buttons.each(function () {
    if ($(this).is(':checked')) {
      enable_submit_button(radio_buttons);
      button_checked = true;
      return false;
    }
  });

  if ( !button_checked ) {
    radio_buttons.each(function () {
      $(this).change(function() {
        enable_submit_button(radio_buttons);
      });
    });
  }
});

function enable_submit_button (radio_buttons) {
  $('.app-submit').prop('disabled', false);
  $('.submit-button-explain').addClass('hide');

  radio_buttons.each(function () {
    $(this).off('change');
  });
}
