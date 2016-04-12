class bud.widgets.Comment extends bud.Widget
  @SELECTOR: '.Comment'

  initialize: ->
    comment_id = @$container.data('comment_id')
    @$comment_row = @$container.parent()
    @$toggler = bud.get("comment-visibility-toggler-#{comment_id}")
    @$edit_menu = bud.get("edit-comment-#{comment_id}")

  toggle: (visible) ->
    @$container.children('.edit_container:visible').toggle()

    bud.Core.destroy_widgets(@$edit_menu)

    if visible
      @$comment_row.css('opacity',  1)
      @$toggler.text('Hide').parent('a').attr 'href', (i, href) -> href.replace /make_visible/, 'hide'
    else
      @$comment_row.css('opacity',  0.5)
      @$toggler.text('Show').parent('a').attr 'href', (i, href) -> href.replace /hide/, 'make_visible'

    bud.Core.init_widgets(@$edit_menu)
