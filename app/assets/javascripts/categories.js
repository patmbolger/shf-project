$(function() {
  'use strict';

  $('body').on('ajax:complete', '.delete-category', removeCategory);

  $('body').on('ajax:complete', '.edit-category-button', showEditRow);

  $('body').on('ajax:complete', '.edit-category-cancel-button', showDisplayRow);

  $('body').on('ajax:complete', '.edit-category-form', handleFormResults);

  $('#new-category-button').on('ajax:complete', showNewCategoryRow);

  $('body').on('click', '.new-category-cancel-button', removeNewCategoryRow);

});

function showEditRow(e, response) {
  if (Utility.checkHttpError(response) === false) {
    var data = JSON.parse(response.responseText);

    // Receiving an edit row from server - replace display row with that
    var $displayRow = $('#category-display-row-' + data.business_category_id);

    $displayRow.replaceWith(data.edit_row);
  }
}

function showDisplayRow(e, response) {
  if (Utility.checkHttpError(response) === false) {
    var data = JSON.parse(response.responseText);

    // Receiving display row from server - replace display row with that
    var $editRow = $('#category-edit-row-' + data.business_category_id);

    $editRow.replaceWith(data.display_row);
  }
}

function showNewCategoryRow(e, response) {
  if (Utility.checkHttpError(response) === false) {
    var data = JSON.parse(response.responseText);

    // Receiving new-cat row from server - add to top of categories table
    $('#business_categories').prepend(data.new_row);
  }
}

function removeNewCategoryRow(e, response) {
  removeThisRow(this);
}

function removeThisRow(this_one) {
  // Remove the parent table row within which this row exists
  $(this_one).closest('tr.category-edit-row').remove();
}

function handleFormResults(e, response) {
  if (Utility.checkHttpError(response) === false) {
    var data = JSON.parse(response.responseText);

    if (Utility.checkActionError(response, data) === false) {
      // Receiving a display row from server
      // If we find a matching edit row, replace that with the display row
      // If not, the display row is for a *new* category - prepend to table.

      var $editRow = $('#category-edit-row-' + data.business_category_id);
      if ($editRow.length == 1) {
        $editRow.replaceWith(data.display_row);
      } else {
        $('#business_categories').prepend(data.display_row);

        // Remove the edit row where the category was created
        removeThisRow(this);
      }

    } else {
      $('#category-edit-errors').html(data.errors);
    }
  }
}

function removeCategory(e, response) {

  if (Utility.checkHttpError(response) === false) {
    var data = JSON.parse(response.responseText);

    // remove row containing the 'delete-category' link
    $(e.target.closest('tr')).fadeOut(800);
  }
}
