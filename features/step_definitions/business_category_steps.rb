And(/^the following business categories exist$/) do |table|
  table.hashes.each do |business_category|
    FactoryBot.create(:business_category, business_category)
  end
end


And(/^I navigate to the business category edit page for "([^"]*)"$/) do |name|
  business_category = BusinessCategory.find_by(name: name)
  visit path_with_locale(edit_business_category_path(business_category))
end

And(/^I select "([^"]*)" Category/) do |element|
  # You must use a driver that supports javascript if using this step.

  # 5/27/2018 - we are using "collection_check_boxes" helper in the appication
  # form.  This sets a hidden field that ensures that business_categories (for
  # the membership application) is updated even if no categories are checked in
  # the form (see "Gotcha" in documentation for that method).
  # However, this hidden field has the same name as all of the checkboxes in the
  # collection.  As a result, all tested JS-capable drivers (Chrome, Selenium,
  # Poltergeist) fail to find the checkbox unless we set "visible" to either
  # :false or :any.
  # Also the capybara method for checking a checkbox ("page.check(element)")
  # fails becuase it first executes a "find" for the element and that fails
  # for the same reason (and there no way to override this).
  # Hence the need to execute some JS to check the checkbox.

  ele = find :field, element, visible: :any
  page.evaluate_script("$(#{ele[:id]}).prop('checked', true)")
end

And(/^I unselect "([^"]*)" Category/) do |element|
  # See comments above

  ele = find :field, element, visible: :any
  page.evaluate_script("$(#{ele[:id]}).prop('checked', false)")
end

Given(/^I am on the business category "([^"]*)"$/) do |name|
  business_category = BusinessCategory.find_by(name: name)
  visit path_with_locale(business_category_path(business_category))
end

And(/I should( not)? see "([^"]*)" in the business categories table$/) do | negate, cmpy |
  step %{I should#{negate} see xpath "tr[td//text()[contains(., '#{cmpy}')]]"}
end
