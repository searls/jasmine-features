
Given /^I open the fixture page$/ do
  visit '/'
  page.should have_content "Loaded!"
end

Given /^I configure jasmine-features to use a different jQuery$/ do 
  page.execute_script("window.jasmine.features.using({jQuery: window.jQuery_1_6_4})")
end

When /^I run all client\-side functional tests$/ do
  page.execute_script("window.jasmine.features.run()")
end

Then /^I see no client\-side functional failures$/ do
  results = page.find("#jasmine_features_results.finished")
  unless results[:class].include? "passed"
    fail results.text
  end
end

