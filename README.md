# jasmine-features

[![Build Status](https://secure.travis-ci.org/searls/jasmine-features.png)](http://travis-ci.org/searls/jasmine-features)

**[Download the latest version here](https://github.com/searls/jasmine-features/archives/master)**.

jasmine-features is a jasmine add-on that makes it easier to write functional tests with Jasmine. It provides a custom reporter, a browser automation DSL, and examples for how to piggyback on Cucumber steps for inclusion with your tests' full stack test suite.

It depends on jQuery & Underscore.

## When to use jasmine-features

tl;dr use jasmine for unit tests and don't use jasmine-features without good cause.

### Jasmine is for unit tests

First things first: **[jasmine is designed for unit tests!](https://twitter.com/dwfrank/status/164583104542023680)** A unit test has these attributes:

* Does not load data over a network, file, or database
* Tests only the code, does not depend on the broader application's environment or configuration
* Specifies a single unit (e.g. an object or function) at a time, and is not concerned with the behavior of the application after all the units have been glued together.

Taking things even further, the present author believes jasmine works best for *isolated* unit tests. An isolated unit test:

* Uses [test doubles](http://en.wikipedia.org/wiki/Test_double) in place of the actual dependencies & collaborators of the unit being specified (jasmine provides a great [spy API](https://github.com/pivotal/jasmine/wiki/Spies) for this)

### Jasmine is not for acceptance tests

There are all sorts of great existing tools for writing acceptance tests. They should be considered before (and I'd expect, already in use) before adding jasmine-features to the mix. Additionally, a "full-stack" acceptance test tool will probably be necessary in order to include your tests in continuous integration.

* For Ruby, there's [Cucumber](http://cukes.info/)/[Steak](https://github.com/cavalle/steak)/[RSpec](http://rspec.info/) + [Capybara](https://github.com/jnicklas/capybara)

* For all sorts of other environments, there's [Selenium](http://seleniumhq.org/)

And in addition to being feature-rich, these tools provide a number of advantages that a pure intra-browser acceptance test would struggle to provide. Most importantly, traditional acceptance tests can and should control the full-stack environment (database environment, test data, server software, browser automation, teardown between tests).

### So when should I use jasmine-features for acceptance tests?

If your current acceptance tests are too slow.

For many projects, acceptance tests are **very very slow**. On a complex Rails project, it's not uncommon for each Cucumber scenario to require tens of seconds to get started. This can be a huge productivity drain if you're using acceptance tests to practice [behavior-driven development](http://www.knwang.com/behavior-driven-outside-in-development-explai). In BDD, any significant lag in your feedback loop (either in your acceptance tests or your unit tests) will undercut a huge part of BDD's value: **focus**.

jasmine-features is a way to steal back fast feedback from your project's acceptance test tool. It does this by allowing you to run the same functional test (a) manually from your browser via the console or a bookmarklet or (b) automatically from your existing acceptance test tool. In jasmine-features, you'd write your own integrated/functional tests with jasmine and include them on the page in non-production environments.

## How to use jasmine-features

### Add jasmine, jasmine-features, and your tests to the page

To run functional tests within your existing page, then jasmine, jasmine-features, and your app's tests need to be loaded in your page's non-production code. Here's the example from this repo's [index.erb](https://github.com/searls/jasmine-features/blob/master/views/index.erb):

``` erb
<% unless ENV['RACK_ENV'] == "production" %>
  <script type="text/javascript" src="features/support/jasmine.js"></script>
  <script type="text/javascript" src="features/support/dist/jasmine-features.js"></script>

  <script type="text/javascript" src="features/support/helpers/jasmine-given-0.0.6.js"></script>

  <script type="text/javascript" src="features/form_feature.js"></script>
<% end %>
```

### Write a feature test

Here's a very simple example feature test from this repo in [form_feature.coffee](https://github.com/searls/jasmine-features/blob/master/public/features/form_feature.coffee).

[Note that this example uses [CoffeeScript](http://coffeescript.org) and [jasmine-given](https://github.com/searls/jasmine-given)]

``` coffeescript
Feature "simple form", ->
  Given -> fillIn "firstName", with: "santa"
  Given -> fillIn "lastName", with: "claus"
  Given -> click '#submitButton'
  Then -> findContent "Submitted!"
```

The `Feature` function is used in a way that's similar to Jasmine's `describe`. In addition to allowing the tests to be run multiple times without loading the page, it will help ensure that your acceptance tests won't be executed along with your unit specs.

#### Capybara-ish DSL

jasmine-features adds a handful of methods that are similar to [Capybara](https://github.com/jnicklas/capybara)'s DSL. At present, they are:

* **click** (*selector*) - clicks on whatever matches the selector
* **fillIn** (*name or selector*, { with: *value*}) - fill in a form field. Currently works with text `input` fields, checkboxes, and `select` fields
* **check** (*name or selector*) - check a checkbox matching the name or selector
* **uncheck** (*name or selector*) - uncheck a checkbox matching the name or selector
* **drag** (*selector*, { to: *selector*}) - drags an element at the provided selector to the provided "to" selector
* **within** (*selector*, *function actions*) - limits the scope of the DSL actions in the provided function to that of the provided selector.
* **findContent** (*text*) - searches the page (or `within` scope) for the provided text. Returns true or false and will fail the test if the text is not found.

Each of the provided DSL methods (unlike most jQuery interactions) are guarded by asserts as appropriate (for example, `fillIn` will first expect the input to exist, then expect the value was actually set after invoking `$.fn.val()`).


### Executing your tests

Your jasmine-feature tests can be kicked off by invoking `jasmine.features.run()` from a console or a bookmarklet. The tests' results will be appended into a simple `div` at the end of the page's body as well as to the browser's console log (if present). If your tests are careful to clean up after each run, they can be run multiple times without refreshing the page.

#### Bookmarklet

Here's an example of a bookmarklet one could use to run their features: `javascript:jasmine.features.run()`

#### Cucumber

Similarly, the same test can be kicked off with Cucumber. This way, the tests you write with jasmine-features can easily be included as part of your project's continuous integration build and/or tested under a number of different application configurations. 

Take for example, this feature file:

``` gherkin
Feature:

  Background:
    Given I open the fixture page

  Scenario: client-side functional tests
    When I run all client-side functional tests
    Then I see no client-side functional failures

```

And step definitions like these:

``` ruby

Given /^I open the fixture page$/ do
  visit '/'
  page.should have_content "Loaded!"
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

```

### Try it yourself

This repo comes with an example configuration that you can run it yourself, including a Sinatra application, unit spec suite, and cucumber tests that invoke jasmine-features. 

To try it out, just clone this repo, run `bundle install`, and run the server:

``` bash
bundle exec shotgun
```

Then you can visit [http://localhost:9393](http://localhost:9393) and run the tests by invoking `jasmine.features.run()`.

To run Cucumber (it's configured to use capybara-webkit, which requires the qt library to be installed):

``` bash
bundle exec cucumber
```

You could also run the entire build (if you have npm & coffee-script installed), which will run the specs, compile the source to `dist/`, and then run the cukes: 

``` bash
bundle exec rake
```

