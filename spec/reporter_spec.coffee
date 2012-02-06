describe "Feature", ->
  Given -> Feature("some feature", @feature = jasmine.createSpy())
  Then -> expect(jasmine.features.queue[0]).toEqual
    name: "some feature"
    suite: @feature

describe "FeatureReporter", ->
  Given -> @subject = new jasmine.features.FeatureReporter
  Then -> @subject instanceof jasmine.JsApiReporter


describe "jasmine.features.run", ->
  afterEach -> $('#jasmine_features_results').remove()
  afterEach -> jasmine.features.queue = []

  Given -> @fakeEnv =
    execute: jasmine.createSpy()
    reporter:
      subReporters_: []
  Given -> @fakeJasmine =
    features: jasmine.features
    getEnv: => @fakeEnv

  describe "executing jasmine", ->
    When -> jasmine.features.run(@fakeJasmine)
    Then -> @fakeEnv.reporter.subReporters_[0] instanceof jasmine.features.FeatureReporter
    Then -> expect(@fakeEnv.execute).toHaveBeenCalled()

  describe "appending results markup to the page", ->
    context "doesn't exist yet", ->
      When -> jasmine.features.run(@fakeJasmine)
      Then -> $('#jasmine_features_results').length == 1

    context "already exists (and has old classes on it)", ->
      Given -> @$results = affix('#jasmine_features_results.finished.passed')
      When -> jasmine.features.run(@fakeJasmine)
      Then -> expect(@$results.hasClass('finished')).toBe(false)
      Then -> expect(@$results.hasClass('passed')).toBe(false)

  describe "invoking each Feature as a describe()", ->
    #TODO - would jasmine.getEnv().describe work? More consistent
    Given -> @feature1 = name: "1", suite: jasmine.createSpy()
    Given -> @feature2 = name: "2", suite: jasmine.createSpy()
    Given -> Feature(@feature1.name,@feature1.suite)
    Given -> Feature(@feature2.name,@feature2.suite)

    Given -> spyOn(window, "describe")

    When -> jasmine.features.run(@fakeJasmine)

    Then -> expect(window.describe).toHaveBeenCalledWith(@feature1.name,@feature1.suite)
    Then -> expect(window.describe).toHaveBeenCalledWith(@feature2.name,@feature2.suite)

  describe "results", ->
    When -> @reporter = jasmine.features.run(@fakeJasmine)
    describe "~ when it's done", ->
      Given -> @superfluousMessage = "I don't matter"
      Given -> @realErrorMessage = "I do matter"
      Given -> spyOn(console, "log") #this may asplode in some browsers.. :-/

      context "passing", ->
        Given -> spyOn(@reporter, "results").andReturn [
          {result: "passed", messages:[ toString: (=> @superfluousMessage), passed: (-> true) ]}
        ]
        When -> @reporter.reportRunnerResults()
        Then -> $('#jasmine_features_results').hasClass('finished')
        Then -> $('#jasmine_features_results').hasClass('passed')
        Then -> expect($('#jasmine_features_results').text()).toContain("Results: 1 passed, 0 failed")
        Then -> expect(console.log).toHaveBeenCalledWith("Results: 1 passed, 0 failed",jasmine.any(Object),@reporter.results())
        Then -> expect($('#jasmine_features_results pre').text()).not.toContain(@superfluousMessage)

      context "failing", ->
        Given -> spyOn(@reporter, "results").andReturn [
          {result: "failed", messages:[ {toString: (=> @realErrorMessage), passed: (-> false)} ]}
          {result: "passed", messages:[ toString: (=> @superfluousMessage), passed: (-> true) ]}
          {result: "failed", messages:[ {toString: (=> @realErrorMessage+"2"), passed: (-> false)} ]}
        ]
        When -> @reporter.reportRunnerResults()
        Then -> $('#jasmine_features_results').hasClass('finished')
        Then -> !$('#jasmine_features_results').hasClass('passed')
        Then -> expect($('#jasmine_features_results').text()).toContain("Results: 1 passed, 2 failed")
        Then -> expect(console.log).toHaveBeenCalledWith("Results: 1 passed, 2 failed",jasmine.any(Object),@reporter.results())
        Then -> expect($('#jasmine_features_results pre').text()).not.toContain(@superfluousMessage)
        Then -> expect($('#jasmine_features_results pre').text()).toContain(@realErrorMessage)
        Then -> expect($('#jasmine_features_results pre').text()).toContain(@realErrorMessage+"2")



