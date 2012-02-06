describe "jasmine.features.using", ->
  fakeJquery = -> {fn:{extend:(->)},extend:(->)}

  describe "setting $", ->
    context "global (default) jQuery", ->
      When -> jasmine.features.using()
      Then -> jasmine.features.$ == $

    context "custom jQuery", ->
      Given -> @fakeJquery = fakeJquery()
      When -> jasmine.features.using(jQuery: @fakeJquery)
      Then -> expect(jasmine.features.$).toEqual(@fakeJquery)

  describe "kicks off the dsl", ->
    Given -> spyOn(jasmine.features, "addDsl")
    When -> jasmine.features.using(jQuery: fakeJquery())
    Then -> expect(jasmine.features.addDsl).toHaveBeenCalledWith(jasmine.features.$)

  describe "adds $.fn.simulate", ->
    context "simulate is not defined", ->
      When -> jasmine.features.using(jQuery: fakeJquery())
      Then -> expect($.fn.simulate).toBeDefined()

    context "simulate is defined", ->
      Given -> $.fn.simulate = @bogusSimulate = "blah"
      When -> jasmine.features.using(jQuery: fakeJquery())
      Then -> expect($.fn.simulate).toBe(@bogusSimulate)



