describe "jasmine.features.dsl", ->
  Given -> jasmine.features.using(jQuery: $)
  Given -> @fakeMatchers = jasmine.createSpyObj('matchers',['toBeAttached','toEqual', 'toBe'])
  Given -> @fakeExpect = jasmine.createSpy().andReturn(@fakeMatchers)
  Given -> @subject = jasmine.features.addDsl($,@fakeExpect)

  describe ".within", ->
    Given -> affix('.panda').affix('a.secret.win').on('click',@winSpy = jasmine.createSpy())
    Given -> affix('a.secret.fail').on('click',@failSpy = jasmine.createSpy())
    Given -> @subject.within '.panda', =>
      @subject.click('a.secret')
    Then -> expect(@winSpy).toHaveBeenCalled()
    Then -> expect(@failSpy).not.toHaveBeenCalled()

  describe ".click", ->
    Given -> @captor = jasmine.captor()
    Given -> @$foo = affix('#foo').on('click',@handler = jasmine.createSpy())
    When -> @subject.click('#foo')
    Then( -> expect(@handler).toHaveBeenCalledWith(@captor.capture()))
    .Then( -> @captor.value instanceof $.Event)
    .Then( -> @captor.value.target == @$foo[0])
    .Then( -> @captor.value.type == 'click')

  describe ".fillIn with:", ->
    Given -> @val = "some text"

    describe "the $.event handler", ->
      Given -> @captor = jasmine.captor()
      Given -> @$foo = affix('input[type="text"][name="foo"]').on('change',@handler = jasmine.createSpy())
      When -> @subject.fillIn('foo', with: @val)
      Then( -> expect(@handler).toHaveBeenCalledWith(@captor.capture()))
      .Then( -> @captor.value instanceof $.Event)
      .Then( -> @captor.value.target == @$foo[0])
      .Then( -> @captor.value.type == 'change')

    describe "setting the value", ->

      context "input[type=text]", ->
        context "by name", ->
          Given -> @$foo = affix('input[type="text"][name="foo"]')
          When -> @subject.fillIn('foo', with: @val)
          Then -> expect(@$foo.val()).toBe(@val)

        context "by some other selector", ->
          Given -> @$foo = affix('input#foo[type="text"]')
          When -> @subject.fillIn('#foo', with: @val)
          Then -> expect(@$foo.val()).toBe(@val)

      context "input[type=checkbox]", ->
        Given -> @val = true

        context "by name", ->
          Given -> @$foo = affix('input[type="checkbox"][name="foo"]')
          When -> @subject.fillIn('foo', with: @val)
          Then -> expect(@$foo.is(":checked")).toBe(true)

        context "by some other selector", ->
          Given -> @$foo = affix('input#foo[type="checkbox"]')
          When -> @subject.fillIn('#foo', with: @val)
          Then -> expect(@$foo.is(":checked")).toBe(true)

  describe ".check", ->
    Given -> @val = true

    context "by name", ->
      Given -> @$foo = affix('input[type="checkbox"][name="foo"]')
      When -> @subject.check('foo')
      Then -> expect(@$foo.is(":checked")).toBe(true)

      context "~unchecking it with check", ->
        When -> @subject.check('foo',false)
        Then -> expect(@$foo.is(":checked")).toBe(false)

    context "by some other selector", ->
      Given -> @$foo = affix('input#foo[type="checkbox"]')
      When -> @subject.check('#foo')
      Then -> expect(@$foo.is(":checked")).toBe(true)

  describe ".uncheck", ->
    context "by name", ->
      Given -> @$foo = affix('input[type="checkbox"][name="foo"][checked="checked"]')
      When -> @subject.uncheck('foo')
      Then -> expect(@$foo.is(":checked")).toBe(false)

    context "by some other selector", ->
      Given -> @$foo = affix('input#foo[type="checkbox"]')
      When -> @subject.uncheck('#foo')
      Then -> expect(@$foo.is(":checked")).toBe(false)

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

  describe ".findContent", ->
    context "exists on the page", ->
      Given -> affix('div').text("Yay")
      When -> @result = @subject.findContent("Yay")
      Then -> @result == true
      Then -> expect(@fakeExpect).toHaveBeenCalledWith(true)
      Then -> expect(@fakeMatchers.toBe).toHaveBeenCalledWith(true)
    
    context "does not exist", ->
      When -> @result = @subject.findContent("Boo")
      Then -> @result == false
      Then -> expect(@fakeExpect).toHaveBeenCalledWith(false)
      Then -> expect(@fakeMatchers.toBe).toHaveBeenCalledWith(true)

    context "using within", ->
      Given -> affix('.foo').text("Yay")
      Given -> affix('.bar')
      When -> @subject.within '.bar', => 
        @result = @subject.findContent("Yay")
      Then -> @result == false 

    #context "does not exist on the page"
