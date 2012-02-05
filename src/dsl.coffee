jasmine ||= {}
jasmine.features ||= {}
jasmine.features.dsl = ->
  o$ = $

  within: (selector, action) ->
    o$ = (s) -> $(s,selector)
    action()
    o$ = $
  click: (selector) ->
    expect(selector).toBeAttached()
    o$(selector).trigger('click')
  fillIn: (name, options) ->
    $input = o$(":input[name=#{name}]")
    expect($input).toBeAttached()
    switch $input.attr('type')
      when "checkbox"
        check(name,options.with)
        expect($input).toBeChecked(options.with)
      else
        $input.val(options.with).trigger('change')
        expect($input).toHaveValue(options.with)
  check: (name, doCheckIt = true) ->
    $checkbox = o$(":checkbox[name=#{name}]")
    $checkbox.attr('checked',doCheckIt).trigger('change')
  uncheck: (name) ->
    $checkbox = o$(":checkbox[name=#{name}]")
    $checkbox.attr('checked',false).trigger('change')
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


#globalization
_(window).extend(jasmine.features.dsl())
