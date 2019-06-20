var categories = {

  init: function() {
    'use strict';

    $('body').on('ajax:complete', '.delete-category', categories.removeCategory);

    $('body').on('ajax:complete', '.edit-category-button', categories.showEditRow);

    $('body').on('ajax:complete', '.edit-category-cancel-button', categories.showDisplayRow);

    $('body').on('ajax:complete', '.edit-category-form', categories.handleFormResults);

    $('#new-category-button').on('ajax:complete', categories.showNewCategoryRow);

    $('body').on('click', '.new-category-cancel-button', categories.removeNewCategoryRow);
  },

  showEditRow: function(e, response) {
    if (Utility.checkHttpError(response) === false) {
      var data = JSON.parse(response.responseText);

      // Receiving an edit row from server - replace display row with that
      var $displayRow = $('#category-display-row-' + data.business_category_id);

      $displayRow.replaceWith(data.edit_row);
    }
  },

  showDisplayRow: function(e, response) {
    if (Utility.checkHttpError(response) === false) {
      var data = JSON.parse(response.responseText);

      // Receiving display row from server - replace display row with that
      var $editRow = $('#category-edit-row-' + data.business_category_id);

      $editRow.replaceWith(data.display_row);
    }
  },

  showNewCategoryRow: function(e, response) {
    if (Utility.checkHttpError(response) === false) {
      var data = JSON.parse(response.responseText);

      // Receiving new-cat row from server - add to top of categories table
      $('#business_categories').prepend(data.new_row);
    }
  },

  removeNewCategoryRow: function(e, response) {
    categories.removeThisRow(this);
  },

  removeThisRow: function(this_one) {
    // Remove the parent table row within which this row exists
    $(this_one).closest('tr.category-edit-row').remove();
  },

  handleFormResults: function(e, response) {
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
          categories.removeThisRow(this);
        }

      } else {
        $('#category-edit-errors').html(data.errors);
      }
    }
  },

  removeCategory: function(e, response) {
    if (Utility.checkHttpError(response) === false) {
      var data = JSON.parse(response.responseText);

      // remove row containing the 'delete-category' link
      $(e.target.closest('tr')).fadeOut(800);
    }
  }
}
