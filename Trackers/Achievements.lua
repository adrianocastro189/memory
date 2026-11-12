--[[
Achievements: screenshot on ACHIEVEMENT_EARNED (memory.screenshotOnAchievement)
and a count per achievement. Disabled automatically on clients without the
achievement event or API (unconfirmed whether WoW: Forever has achievements).
]]
local _, ns = ...

ns.Trackers.register('achievements', {
  label = 'Achievements',
  apis = { 'GetAchievementInfo' },
  events = { 'ACHIEVEMENT_EARNED' },
  setup = function(on)
    on('ACHIEVEMENT_EARNED', function(_, achievementID)
      if not ns.Repository.isReady() then return end
      local id = ns.Safe.value(achievementID)
      local _, name = ns.Safe.api('GetAchievementInfo', id)
      name = ns.Safe.str(name) or ('Achievement ' .. tostring(id or '?'))
      ns.record({
        category = 'misc', path = { 'achievements', name }, interaction = 'earn',
        verbs = { past = 'earned', present = 'earn', subject = name },
        quiet = true,
      })
      if ns.Settings.get('screenshotOnAchievement') then
        ns.Reminders.screenshot('Achievement earned on ' .. ns.Util.formatDate(ns.Util.today()))
      end
    end)
  end,
})
