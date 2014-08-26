class bud.widgets.BenefitToggler extends bud.Widget
  @SELECTOR: '.Benefits'

  initialize: ->
    if @$container.children('div:not(.hidden)').length > 0
      @show_next()
    else
      @show_next()
      @show_next()

    container = @$container
    @$container.find('input[name*="benefit"]').on 'keyup', ->
      currentInput = $(this)
      nextInput = container.find("input[name='benefits[#{currentInput.data('index') + 1}]']")
      if currentInput.val() == "" && nextInput.val() == ""
        nextInput.parent().addClass('hidden')
      else
        nextInput.parent().removeClass('hidden')

  show_next: =>
    @$container.children('div.hidden:first').removeClass('hidden')
