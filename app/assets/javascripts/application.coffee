# This is a manifest file that'll be compiled into application.js, which will include all the files
# listed below.
#
# Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
# or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.

# It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
# compiled file.

# Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
# about supported directives.

#= require jquery_extensions
#= require core
#= require helpers
#= require_tree .

$(document).ready ->
  unless window['bud']['layout']['locked']
    bud.Core.initialize()

$(document).on 'focus', 'input, textarea', ->
  if (navigator.userAgent.match(/Mobi/))
    $('.HidesOnMobileInput').css('display', 'none')

$(document).on 'focusout', 'input, textarea', ->
  if (navigator.userAgent.match(/Mobi/))
    $('.HidesOnMobileInput').css('display', 'block')
