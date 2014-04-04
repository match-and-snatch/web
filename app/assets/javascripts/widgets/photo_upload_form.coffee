#= require ./form

class bud.widgets.PhotoUploadForm extends bud.widgets.Form
  @SELECTOR: '.PhotoUploadForm'
  @TRANSLOADIT_SCRIPT_PATH: '//assets.transloadit.com/js/jquery.transloadit2-latest.js'

  initialize: ->
    super
    @$target = bud.get(@$container.data('target'))
    bud.sub('post', @on_post)
    bud.Ajax.getScript(bud.widgets.PhotoUploadForm.TRANSLOADIT_SCRIPT_PATH).done(@on_script_loaded)

  on_script_loaded: =>
    @$container.attr('enctype', 'multipart/form-data')
    @$container.transloadit(
      wait: true
      triggerUploadOnFileSelection: true
      fields: "input[name=slug]"
      modal: false
      onProgress: (bytesReceived, bytesExpected, assembly) =>
        progress = (bytesReceived / bytesExpected * 100).toFixed(2) + '%'
        $('.progress-bar-info').width(progress)
        $('.percentage').text(progress)
      onUpload: (upload, assembly) =>
        @$target.prepend("<div>#{upload.name} is uploaded.</div>")
      onSuccess: (assembly)->
        $('#uploading > .file_status').addClass('hidden')
      onStart: (assembly)->
        $('#uploading > .file_status').removeClass('hidden')
    )

  on_post: =>
    bud.clear_html(@$target)

  #can't unbind transloadit callbacks
  on_replace: (response) =>
    $(@$container).unbind('submit.transloadit');
    super
    @on_script_loaded()
    @$container.find('textarea[name=transloadit]').remove()