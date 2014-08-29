class bud.widgets.BenefitToggler extends bud.Widget
  @SELECTOR: '.Benefits'

  initialize: ->
    @$benefits = @get_target()
    @$benefit_inputs = @$benefits.find('input[type=text]')
    @$hiddable_benefits = []

    @$benefit_inputs.keyup @on_keyup
    @$benefit_inputs.focusout @on_focusout
    @hide_inputs()

  on_keyup: (e) =>
    currentInput = $(e.currentTarget)
    currentInputIndex = @$benefit_inputs.index(currentInput)

    nextInputIndex = currentInputIndex + 1
    nextInput   = $(@$benefit_inputs[nextInputIndex])
    nextBenefit = $(@$benefits[nextInputIndex])

    if _.isEmpty(currentInput.val())
      if _.isEmpty(nextInput.val())
        nextBenefit.hide()
      else
        @$hiddable_benefits[currentInputIndex] = true if currentInputIndex != 0
    else
      nextBenefit.show()

    bud.pub('popup.autoplace.benefits-editor')

  on_focusout: (e) =>
    currentInput = $(e.currentTarget)
    currentInputIndex = @$benefit_inputs.index(currentInput)
    if @$hiddable_benefits[currentInputIndex]
      $(@$benefits[currentInputIndex]).hide()
      @$hiddable_benefits[currentInputIndex] = false

  hide_inputs: ->
    s = @$benefit_inputs.filter(->
      !_.isEmpty $(this).val()
    ).length
    index = if s > 0 then s + 1 else 2
    @$benefits.slice(index, @$benefits.length).hide()
