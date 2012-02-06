jasmine ||= {}
jasmine.features ||= {}
jasmine.features.addDsl = ($) ->
  o$ = $

  find = (nameOrSelector,type=":input") ->
    $r = o$("#{type}[name=#{nameOrSelector}]")
    $r = o$(nameOrSelector) if $r.length == 0
    $r

  dsl =
    within: (selector, action) ->
      o$ = (s) -> $(s,selector)
      action()
      o$ = $
    click: (selector) ->
      expect(selector).toBeAttached()
      o$(selector).trigger('click')
    fillIn: (name, options) ->
      $input = find(name)
      expect($input).toBeAttached()
      switch $input.attr('type')
        when "checkbox"
          check(name,options.with)
        else
          $input.val(options.with).trigger('change')
          expect($input.val()).toEqual(options.with)
    check: (name, doCheckIt = true) ->
      $checkbox = find(name,":checkbox")
      $checkbox.attr('checked',doCheckIt).trigger('change')
      expect($checkbox.is(':checked')).toBe(doCheckIt)
    uncheck: (name) ->
      dsl.check(name,false)
    drag: (selector,options) ->
      $from = o$(selector)
      $to = o$(options.to)

      $from.simulate 'drag',
        dx: $to.offset().left - $from.offset().left
        dy: $to.offset().top - $from.offset().top

  _(window).extend(dsl)
  dsl
