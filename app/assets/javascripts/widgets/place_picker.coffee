class bud.widgets.PlacePicker extends bud.Widget

  @SELECTOR: '.PlacePicker'

  initialize: ->
  	@$container.geocomplete()
  	# @$container.val()
  	# @location = @$container.val()
