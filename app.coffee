{$}                    = require './mvc'
{Animator, Controller} = require './animator'

module.exports = ->
  
  initAnimator = (model) ->
    controller = new Controller({controls : $('#controls')})
    animator   = new Animator({stage : $('svg #stage'), model : $(model), controller})
    
  $.get('model.svg', initAnimator)