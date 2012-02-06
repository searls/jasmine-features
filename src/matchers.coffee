beforeEach ->
  this.addMatchers
    toBeAttached: (within = 'body') ->
      $el = $(this.actual)
      $within = $(within)
      isContainedWithin = $.contains($within[0],$el[0])
      this.message = -> "Expected '#{$el.selector}' to be contained within '#{$within.selector}'"
      isContainedWithin
