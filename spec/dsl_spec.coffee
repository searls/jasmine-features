describe "jasmine.features.dsl", ->
  Given -> jasmine.features.using(jQuery: $)

  #This let's us set up expectations of the dsl's expectations with didExpect()
  Given -> @fakeMatchers = jasmine.createSpyObj('expect()',['toBeAttached','toEqual', 'toBe'])
  Given -> @fakeExpect = jasmine.createSpy("expect").andReturn(@fakeMatchers)
  didExpect=null
  Given ->
    didExpect = (actual) =>
      obj = {}
      expect(@fakeExpect).toHaveBeenCalled()

      nodifyObj = (ar) ->
        clone = _(ar).clone()
        _(ar).each (v,k) ->
          if v.jquery
            clone[k] = v.toArray()
        clone

      ensureCalledWith = (spy,args) =>
        expectedArgs = jasmine.util.argsToArray(args)
        argsMatched = _(spy.calls).any (call) =>
          jasmine.getEnv().equals_(nodifyObj(call.args),nodifyObj(expectedArgs))
        @fail("expect() was not called with [#{expectedArgs}], but was called with #{_(spy.calls).pluck("args").join(" | ")}") unless argsMatched

      ensureCalledWith(@fakeExpect,arguments)

      _(@fakeMatchers).chain().functions().each (f) =>
        obj[f] = =>
          fakeMatcher = @fakeMatchers[f]
          expect(fakeMatcher).toHaveBeenCalled()
          ensureCalledWith(fakeMatcher,arguments)
      obj

  Given -> @subject = jasmine.features.addDsl($,@fakeExpect)

  describe "Clicking links and buttons", ->
    describe ".click", ->

      context "by ID", ->
        Given -> @$link = affix("#link").on('click',@handler = jasmine.createSpy())
        When -> @subject.click("link")
        Then -> didExpect(@$link).toBeAttached()
        Then -> expect(@handler).toHaveBeenCalled()

      xcontext "by Content -- TODO: how to select the closest ancestor containing?", ->
        Given -> @$link = affix("div").text("Hello There!").on('click',@handler = jasmine.createSpy())
        When -> @subject.click("Hello There")
        Then -> didExpect(@$link).toBeAttached()
        Then -> expect(@handler).toHaveBeenCalled()

      context "arbitrary selector", ->
        Given -> @captor = jasmine.captor()
        Given -> @$foo = affix('#foo').on('click',@handler = jasmine.createSpy())
        When -> @subject.click('#foo')
        Then( -> expect(@handler).toHaveBeenCalledWith(@captor.capture()))
        .Then( -> @captor.value instanceof $.Event)
        .Then( -> @captor.value.target == @$foo[0])
        .Then( -> @captor.value.type == 'click')
        .Then( -> didExpect(@$foo).toBeAttached())

    describe ".clickLink", ->
      context "by id", ->
        Given -> @$link = affix("a#link").on('click',@handler = jasmine.createSpy())
        When -> @subject.clickLink("link")
        Then -> didExpect(@$link).toBeAttached()
        Then -> expect(@handler).toHaveBeenCalled()

      context "by link content", ->
        Given -> @$link = affix("a").text('My Link').on('click',@handler = jasmine.createSpy())
        When -> @subject.clickLink("My Link")
        Then -> didExpect(@$link).toBeAttached()
        Then -> expect(@handler).toHaveBeenCalled()

      context "by some filtering selector", ->
        Given -> @$link = affix("a.link").on('click',@handler = jasmine.createSpy())
        When -> @subject.clickLink(".link")
        Then -> didExpect(@$link).toBeAttached()
        Then -> expect(@handler).toHaveBeenCalled()

      context "matching a non-anchor tag", ->
        Given -> @$link = affix("span#link").on('click',@handler = jasmine.createSpy())
        When -> @subject.clickLink("link")
        Then -> didExpect([]).toBeAttached()
        Then -> expect(@handler).not.toHaveBeenCalled()

    describe ".clickButton", ->
      _(["button","input[type=\"button\"]","input[type=\"submit\"]"]).each (selector) ->
        describe "button elements", ->
          Given -> @$button = affix(selector).on('click',@handler = jasmine.createSpy())

          context "by id", ->
            Given -> @$button.attr('id','foo')
            When -> @subject.clickButton('foo')
            Then -> didExpect(@$button).toBeAttached()
            Then -> expect(@handler).toHaveBeenCalled()

          context "by name", ->
            Given -> @$button.attr('name','foo')
            When -> @subject.clickButton('foo')
            Then -> didExpect(@$button).toBeAttached()
            Then -> expect(@handler).toHaveBeenCalled()

          context "by text content", ->
            Given -> @$button.text('foo')
            When -> @subject.clickButton('foo')
            Then -> didExpect(@$button).toBeAttached()
            Then -> expect(@handler).toHaveBeenCalled()

          context "by value", ->
            Given -> @$button.val('foo')
            When -> @subject.clickButton('foo')
            Then -> didExpect(@$button).toBeAttached()
            Then -> expect(@handler).toHaveBeenCalled()

          context "by arbitrary filtering selection", ->
            Given -> @$button.addClass('foo')
            When -> @subject.clickButton('.foo')
            Then -> didExpect(@$button).toBeAttached()
            Then -> expect(@handler).toHaveBeenCalled()

          context "by matching a non-button", ->
            Given -> affix('a').on('click',@handler).text('foo')
            When -> @subject.clickButton('foo')
            Then -> didExpect([]).toBeAttached()
            Then -> expect(@handler).not.toHaveBeenCalled()

  describe "Interacting with forms", ->
    behavesLikeFormField = (config) ->
      andArgs = (x) -> _(x).union(config.args)

      describe ".#{config.method}", ->
        Given -> @$field = affix(config.selector).on('change',@handler = jasmine.createSpy())

        describe "the $.event handler", ->
          Given -> @captor = jasmine.captor()
          When -> @subject[config.method].apply(@,andArgs(config.selector))
          Then( -> expect(@handler).toHaveBeenCalledWith(@captor.capture()))
          .Then( -> @captor.value instanceof $.Event)
          .Then( -> @captor.value.target == @$field[0])
          .Then( -> @captor.value.type == 'change')

        context "choosing by id", ->
          Given -> @$field.attr('id','foo')
          When -> @subject[config.method].apply(@,andArgs('foo'))
          Then -> didExpect(@$field).toBeAttached()
          Then -> config.setTest(@$field) == true
          Then -> didExpect(config.valueFor(@$field)).toBe(config.value)

        context "choosing by label", ->
          Given -> @$field.attr('id','foo')
          Given -> affix('label[for="foo"]').text("Some label")
          When -> @subject[config.method].apply(@,andArgs('Some label'))
          Then -> didExpect(@$field).toBeAttached()
          Then -> config.setTest(@$field) == true

        context "no match", ->
          When -> @subject[config.method].apply(@,andArgs('Some label'))
          Then -> didExpect([]).toBeAttached()
          Then -> config.setTest(@$field) == false

        context "choosing by name", ->
          Given -> @$field.attr('name','pants')
          When -> @subject[config.method].apply(@,andArgs('pants'))
          Then -> didExpect(@$field).toBeAttached()
          Then -> config.setTest(@$field) == true

        context "choosing by a normal selector", ->
          Given -> @$field.attr('name','pants')
          When -> @subject[config.method].apply(@,andArgs(':input[name="pants"]'))
          Then -> didExpect(@$field).toBeAttached()
          Then -> config.setTest(@$field) == true

        context "a matching non-field", ->
          Given -> @$field = affix(config.selector.replace('input','span').replace(/\[type=\"[^\]]*\"\]/,"[type=\"foomail\"]")).attr('name','pants')
          When -> @subject[config.method].apply(@,andArgs('pants'))
          Then -> didExpect([]).toBeAttached()
          Then -> config.setTest(@$field) == false

    behavesLikeFormField
      method: "check"
      selector: "input[type=\"checkbox\"]"
      args: []
      value: true
      setTest: ($field) -> $field.is(":checked")
      valueFor: ($field) -> $field.is(":checked")

    behavesLikeFormField
      method: "uncheck"
      selector: "input[type=\"checkbox\"][checked=\"checked\"]"
      args: []
      value: false
      setTest: ($field) -> $field.attr("checked") != "checked"
      valueFor: ($field) -> $field.is(":checked")

    behavesLikeFormField
      method: "choose"
      selector: "input[type=\"radio\"]"
      args: []
      value: true
      setTest: ($field) -> $field.is(":checked")
      valueFor: ($field) -> $field.is(":checked")

    behavesLikeFormField
      method: "fillIn"
      args: [{with: "My Text"}]
      selector: "input[type=\"text\"]"
      value: "My Text"
      setTest: ($field) -> $field.val() == "My Text"
      valueFor: ($field) -> $field.val()


  describe "Querying", ->
    describe ".findContent", ->
      context "exists on the page", ->
        Given -> affix('div').text("Yay")
        When -> @result = @subject.findContent("Yay")
        Then -> @result == true
        Then -> didExpect(true).toBe(true)

      context "does not exist", ->
        When -> @result = @subject.findContent("Boo")
        Then -> @result == false
        Then -> didExpect(false).toBe(true)

      context "using within", ->
        Given -> affix('.foo').text("Yay")
        Given -> affix('.bar')
        When -> @subject.within '.bar', =>
          @result = @subject.findContent("Yay")
        Then -> @result == false
        Then -> didExpect(false).toBe(true)

  describe "Finding", ->
    describe ".find", ->
      context "exists", ->
        Given -> @$foo = affix('.foo')
        When -> @$result = @subject.find('.foo')
        Then -> @$foo[0] == @$result[0]
        Then -> didExpect(@$foo).toBeAttached()

      context "does not exist", ->
        When -> @$result = @subject.find('.foo')
        Then -> @$result.length == 0
        Then -> didExpect([]).toBeAttached()

      context "exists out of scope", ->
        Given -> @$foo = affix('.foo')
        Given -> @$bar = affix('.bar')
        When ->
          @subject.within '.bar', =>
            @$result = @subject.find('.foo')
        Then -> @$result.length == 0
        Then -> didExpect([]).toBeAttached()

  describe "Scoping", ->
    describe ".within", ->
      Given -> affix('.panda').affix('a.secret.win').on('click',@winSpy = jasmine.createSpy())
      Given -> affix('a.secret.fail').on('click',@failSpy = jasmine.createSpy())
      Given -> @subject.within '.panda', =>
        @subject.click('a.secret')
      Then -> expect(@winSpy).toHaveBeenCalled()
      Then -> expect(@failSpy).not.toHaveBeenCalled()





  describe ".drag to:", ->
    Given -> $.fn.simulate = jasmine.createSpy()
    Given -> @$from = affix('div.panda')
    Given -> @$to = affix('div.bamboo')

    position = ($div,left,top) ->
      $div.css
        position: 'absolute'
        left: left
        top: top

    context "default (0,0) positioning", ->
      When -> @subject.drag '.panda', to: '.bamboo'
      Then -> expect($.fn.simulate).toHaveBeenCalledWith('drag', {dx: 0, dy: 0})
      Then -> expect($.fn.simulate.mostRecentCall.object[0]).toBe(@$from[0])

    context "drags to lower-right", ->
      Given -> position(@$from,30,20)
      Given -> position(@$to,60,40)

      When -> @subject.drag '.panda', to: '.bamboo'
      Then -> expect($.fn.simulate).toHaveBeenCalledWith('drag', {dx: 30, dy: 20})

    context "drags to upper-right", ->
      Given -> position(@$from,50,61)
      Given -> position(@$to,85,30)

      When -> @subject.drag '.panda', to: '.bamboo'
      Then -> expect($.fn.simulate).toHaveBeenCalledWith('drag', {dx: 35, dy: -31})

    context "drags to lower-left", ->
      Given -> position(@$from,45,61)
      Given -> position(@$to,20,90)

      When -> @subject.drag '.panda', to: '.bamboo'
      Then -> expect($.fn.simulate).toHaveBeenCalledWith('drag', {dx: -25, dy: 29})

    context "drags to upper-left", ->
      Given -> position(@$from,123,383)
      Given -> position(@$to,94,201)

      When -> @subject.drag '.panda', to: '.bamboo'
      Then -> expect($.fn.simulate).toHaveBeenCalledWith('drag', {dx: -29, dy: -182})
