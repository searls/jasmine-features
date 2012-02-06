jasmine ||= {}
jasmine.features ||= {}
jasmine.features.using = (config = {}) ->
  config = _(jQuery: $).extend(config)
  jasmine.features.$ = config.jQuery
  jasmine.features.addDsl(jasmine.features.$)
  jasmine.features.addSimulate(jasmine.features.$) unless jasmine.features.$.fn.simulate?
