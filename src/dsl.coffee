jasmine ||= {}
jasmine.features ||= {}
jasmine.features.dsl = ->
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

      delta = _({dx: 0, dy: 0}).chain().
      tap((delta) ->
        offset = $from.offset()
        delta.dx -= offset.left
        delta.dy -= offset.top
      ).tap( (delta) ->
        offset = $to.offset()
        delta.dx += offset.left
        delta.dy += offset.top
      ).value()

      $from.simulate('drag', delta)
  dsl

#globalization
_(window).extend(jasmine.features.dsl())
