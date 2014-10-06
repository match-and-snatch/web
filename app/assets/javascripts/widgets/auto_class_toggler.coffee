# Once page loaded, toggles css class on the container
# @data class [String]
class bud.widgets.AutoClassToggler extends bud.Widget
  @SELECTOR = '.AutoClassToggler'
  initialize: -> @$container.addClass(@data('class'))

