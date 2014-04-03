#= require ./form

class bud.widgets.VideoUploadForm extends bud.widgets.Form
  @SELECTOR: '.VideoUploadForm'
  @TRANSLOADIT_SCRIPT_PATH: '//assets.transloadit.com/js/jquery.transloadit2-latest.js'

  initialize: ->
    super
    @$target = bud.get(@$container.data('target'))
    bud.Ajax.getScript(bud.widgets.VideoUploadForm.TRANSLOADIT_SCRIPT_PATH).done(@on_script_loaded)

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
        @$target.prepend("<div class='alert.alert-success'>#{upload.name} is uploaded.</div>")
      onSuccess: (assembly)->
        $('#uploading > .file_status').addClass('hidden')
      onStart: (assembly)->
        $('#uploading > .file_status').removeClass('hidden')
    )

  #can't unbind transloadit callbacks
  on_replace: (response) =>
    $(@$container).unbind('submit.transloadit');
    super
    @on_script_loaded()
    @$container.find('textarea[name=transloadit]').remove()




