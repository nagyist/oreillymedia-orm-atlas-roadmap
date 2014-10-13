$ ->
  milestones = new map.Milestones(data.milestones)
  origin = new Date(milestones.first().get('created_at')).getTime()
  milestonesView = new map.MilestonesView collection:milestones
