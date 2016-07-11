class bud.widgets.Comment extends bud.Widget
  @SELECTOR: '.Comment'

  initialize: ->
    comment_id = @$container.data('comment_id')
    @$comment_body = bud.get("comment-body-#{comment_id}")
    @$toggler = bud.get("comment-visibility-toggler-#{comment_id}")
    @$edit_menu = bud.get("edit-comment-#{comment_id}")

  toggle: (visible) ->
    @$container.children('.edit_container:visible').toggle()

    if visible
      @$comment_body.removeClass("hidden_content")
      @$toggler.text('Hide').parent('a').attr 'href', (i, href) -> href.replace /make_visible/, 'hide'
    else
      @$comment_body.addClass("hidden_content")
      @$toggler.text('Show').parent('a').attr 'href', (i, href) -> href.replace /hide/, 'make_visible'
