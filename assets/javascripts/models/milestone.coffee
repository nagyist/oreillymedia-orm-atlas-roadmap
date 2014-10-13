class map.Milestone extends Backbone.Model
  
  initialize: ->
    @parse_frontmatter()

  parse_frontmatter: ->
    # see if there is frontmatter
    if @get('description')? and match = @get('description').match(/^\-\-\-([\s\S]*)\-\-\-/m)
      descrip = @get('description')
      @set('description', descrip.replace(/^\-\-\-([\s\S]*)\-\-\-/m,""))
      @frontMatter = YAML.parse(match[1])
      if _.has(@frontMatter, 'start')
        d = new Date(@frontMatter.start)
        @set('created_at', "#{d}")
    @set_duration()
    @set_progress()

  formatted_description: ->
    output = "### <a href='https://github.com/oreillymedia/orm-atlas/issues?milestone=#{@get('number')}' target='_blank'>#{@get('title')}</a>\n"
    output += "#### Start Date: #{(new Date(@get('created_at'))).toDateString()}\n"
    output += "#### Due On: #{(new Date(@get('due_on'))).toDateString()}\n" if @get('due_on')?
    output += @get('description') || ""
    marked(output)

  set_position: (baseTime) ->
    left = map.helpers.time_position(@get('created_at'),baseTime)
    width = map.helpers.days(@get('duration'))*map.helpers.day_width
    @set({left:left, width:width})

  set_progress: ->
    open = @get('open_issues')
    close = @get('closed_issues')
    if open is 0 and close is 0
      p = 0
    else
      p = close/(close+open)*100
    @set('progress',p)

  set_duration: ->
    created_int = new Date(@get('created_at')).getTime()
    if @get('due_on')?
      time_diff = new Date(@get('due_on')).getTime() - created_int
    else if @get('state') is 'closed'
      time_diff = new Date(@get('updated_at')).getTime() - created_int
    else
      time_diff = 10*24*60*60*1000
    @set('duration',time_diff)