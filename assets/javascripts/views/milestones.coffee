class map.MilestonesView extends Backbone.View
  
  el: '#wrapper'
  initialize: ->
    _.each _.range(0,@collection.length / 3), -> $("#wrapper").append("<div class='row'/>")
    @render().el

  renderCalendar: ->
    # This _should_ work.
    last_date = new Date(@collection.latest().get('due_on') || @collection.latest().get('created_at'))
    last_timestamp = last_date.getTime()

    this_month = map.helpers.firstOfMonth(@collection.earliest().get('created_at'))

    # Render the calendar, setting the width of each month based on time
    # between start of this month and the end of the next. Append to the page
    # and increment the month
    while(this_month.getTime() < last_timestamp)
      next_month = map.helpers.nextMonth(this_month)

      left = map.helpers.time_position(this_month, @collection.origin())
      width = Date.getDaysInMonth(this_month.getFullYear(),this_month.getMonth())*map.helpers.day_width

      $('.calendar').append JST['templates/month']({month:this_month.getMonthName(), width:width, left:left, this_month:new Date(this_month), next_month:next_month})


      this_month = next_month
    $('.calendar').append JST['templates/today']({left: map.helpers.time_position((new Date()).getTime(), @collection.origin())})

  render: ->
    t = @
    @collection.sort()
    @collection.each (model) ->
      view = new map.MilestoneView model:model
      for row in $("#wrapper .row")
        if $(row).children().length is 0
          $(row).append view.render().el
          break
        else if $(row).children().last().position().left+$(row).children().last().width() < model.get('left')
          $(row).append view.render().el
          break
    @renderCalendar()

    setTimeout (->
      $('#wrapper').scrollLeft((->
        l = $('.calendar .today').css('left');
        l.replace(/px/,"") - $(window).width()/2
      )())
      map.helpers.setRowHeight()
    ), 100
    @