map.helpers =
  
  today: new Date()
  
  day_width: 25
  
  time_position: (time,baseTime) ->
    diff = (new Date(time)).getTime() - baseTime
    @days(diff)*@day_width
  
  days: (time) ->
    int_time = if typeof time is 'number' then time else time.getTime()
    Math.floor int_time/1000/60/60/24
  
  progress: (open,close) ->
    if open is 0 and close is 0
      0
    else
      close/(close+open)*100
  
  setRowHeight: ->
    $('.row').each ->
      objHeight = 0
      $(this).find('.milestone').each ->
        milestone_height = $(@).css('height').replace(/px/,'')
        if milestone_height > objHeight
          objHeight = milestone_height
      $(this).css('height',objHeight+'px')
  
  firstOfMonth: (date) ->
    d = new Date(date)
    d.setHours(0)
    d.setMinutes(0)
    d.setSeconds(0)
    d.setMilliseconds(0)
    d
  
  nextMonth: (date) ->
    d = new Date(date)
    d.moveToMonth(d.getMonth()+1)