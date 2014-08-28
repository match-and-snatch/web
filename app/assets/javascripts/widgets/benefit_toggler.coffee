class bud.widgets.BenefitToggler extends bud.Widget
  @SELECTOR: '.Benefits'

  initialize: ->
    @$benefits = @get_target()
    @$benefit_inputs = @$benefits.find('input[type=text]')

    @$benefit_inputs.keyup @on_keyup
    @hide_inputs()

  on_keyup: (e) =>
    currentInput = $(e.currentTarget)
    currentInputIndex = @$benefit_inputs.index(currentInput)
    currentBenefit = $(@$benefits[currentInputIndex])

    nextInputIndex = currentInputIndex + 1
    nextInput   = $(@$benefit_inputs[nextInputIndex])
    nextBenefit = $(@$benefits[nextInputIndex])

    if _.isEmpty(currentInput.val())
      if _.isEmpty(nextInput.val())
        nextBenefit.hide()
      else
        currentBenefit.hide()
    else
      nextBenefit.show()

    bud.pub('popup.autoplace.benefits-editor')

  hide_inputs: ->
    s = @$benefit_inputs.filter(->
      !_.isEmpty $(this).val()
    ).length
    index = if s > 0 then s + 1 else 2
    @$benefits.slice(index, @$benefits.length).hide()
