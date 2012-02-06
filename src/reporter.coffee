jasmine ||= {}
jasmine.features ||= {}

class jasmine.features.FeatureReporter extends jasmine.JsApiReporter
  constructor: (whenDone) ->
    super(arguments)
    @whenDone = whenDone

  reportRunnerResults: (runner) ->
    super
    @whenDone.call(@,@,runner)

jasmine.features.Feature = (name,suite) ->
  (jasmine.features.queue ||= []).push(name: name, suite: suite)

jasmine.features.run = (jazmine=jasmine) ->
  $ = jazmine.features.$
  $results = $('#jasmine_features_results')
  if $results.length == 0
    $results = $('<div id="jasmine_features_results"></div>').appendTo('body')
  $results.removeClass()

  _(jazmine.features.queue).each (feature) ->
    describe(feature.name,feature.suite)

  reporter = new jazmine.features.FeatureReporter (reporter) ->
    results = buildResults(reporter.results())
    $('#jasmine_features_results').
      html(results.message).
      addClass('finished').
      toggleClass('passed',results.failed == 0).
      append("<pre>#{results.errors}</pre>")
    console?.log?(results.message, results, reporter.results())

  jazmine.getEnv().reporter.subReporters_ = [reporter]
  jazmine.getEnv().execute()
  reporter

buildResults = (results) ->
  _({passed:0,failed:0}).chain().
    tap((score) -> _(results).each (r) -> score[r.result] += 1).
    tap((score) -> score.message = "Results: #{score.passed} passed, #{score.failed} failed").
    tap((score) -> score.errors = buildErrors(results)).
    value()

buildErrors = (results) ->
  _(results).chain().
    pluck('messages').
    flatten().
    filter((r) -> !r.passed()).
    reduce((memo,result) ->
      "#{memo}\n#{result.toString()}"
    ,'').
    value()


#globalize
window.Feature = jasmine.features.Feature