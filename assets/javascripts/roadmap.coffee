window.milestones = new Backbone.Collection(data.milestones)

window.helpers =
  progress: (open,close) ->
    if open is 0 and close is 0
      0
    else
      close/(close+open)*100

$ ->
  milestones.each (milestone) ->
    console.log milestone.attributes
    $('#wrapper').append JST['milestone'](milestone.toJSON())

  $('.milestone').click ->
    $(@).find('.description').toggle()
