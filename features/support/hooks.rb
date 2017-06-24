Before('@javascript, @poltergeist') do
  Capybara.current_driver = :poltergeist
end

Before('@selenium') do
  # For JS-driven tests that Poltergeist does not handle cleanly.
  Capybara.javascript_driver = :selenium
end

After('@javascript, @poltergeist, @selenium') do
  Capybara.reset_sessions!
  Capybara.current_driver = :rack_test
end
