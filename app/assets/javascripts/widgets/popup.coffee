class bud.widgets.Popup extends bud.Widget
  @SELECTOR: '.Popup'

  initialize: ->
    # Binds on other popups
    $.subscribe("popup.show", @autoclose)

    # Binds on button click
    $.subscribe("popup.toggle.#{@class_name()}", @toggle)

    # Move into proper HTML position
    @$container.appendTo($('body'))

  # Closes when other popup gets opened
  autoclose: (e, widget) => @hide() if widget != @

  # Toggles visibility on trigger click
  toggle: => if @$container.is(':visible') then @hide() else @show()

  show: =>
    # Close other popups
    $.publish("popup.show", [@]);

    # Show this popup
    @$container.show()
    @$container.css('margin-left', "-#{@width()/2}px")
    @$container.css('margin-top', "-#{@height()/2}px")

    # Show overlay
    $.publish("popup.show.overlay");

  hide: =>
    @$container.hide()
    $.publish("popup.hide");

  width: -> @$container.outerWidth()
  height: -> @$container.outerHeight()
