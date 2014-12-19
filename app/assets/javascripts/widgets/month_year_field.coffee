class bud.widgets.MonthYearField extends bud.Widget
  @SELECTOR: '.MonthYearField'

  initialize: ->
    @$container.on('input', @on_keyup)
    @validator = new bud.widgets.Validator(@$container, bud.widgets.Validator) if @$container.attr('validate')

  on_keyup: (e) =>
    @$container.val(@value().replace(/^(\d*)[^\/0-9]+(\d*)$/, '$1$2').
                             replace(/^(\d*)\D+(\d*) \//, '$1$2 \/').
                             replace(/\/ (\d*)\D+(\d*)$/, '\/ $1$2').
                             replace(/.\/./, ' / '))
    val = @value()

    switch val.length
      when 0
        return true
      when 1
        if val == '1' || val == '0'
          return true
        else
          @$container.val("0#{val} / ")
      when 2
        @$container.val("#{val} / ")
      when 4, 5
        @$container.val(val.substring(0, 2))

    if val.length > 9
      @$container.val(val.substring(0, 9))

    return true

  value: ->
    @$container.val()
