Feature:

  Background:
    Given I open the fixture page

  Scenario: client-side functional tests
    When I run all client-side functional tests
    Then I see no client-side functional failures

  Scenario: custom jQuery
    Given I configure jasmine-features to use a different jQuery
    When I run all client-side functional tests
    Then I see no client-side functional failures