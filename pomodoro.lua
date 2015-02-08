--- a pomodoro for awesome.
-- @author [Alejandro Baez](https://twitter.com/a_baez)
-- @copyright 2015
-- @license MIT (see LICENSE)
-- @module pomodoro

local wibox = require("wibox")
local awful = require("awful")
local naughty = require("naughty")

local pomodoro = {}
p = pomodoro

--- quick convert to seconds
-- @param min the amounts you want to be converted to seconds.
local tosec = function(min) return min * 60 end

--- in minutes settings for pomodoro. use tosec to convert to seconds
local conf = {
    pause   = tosec(5),
    work    = tosec(35),
    limit   = tosec(60) -- limit for call
}

--- the status of the widget
local status  = {
    true,
    missing = p.conf.work
}

--- dialog to be shown
local dialog = {
    pause = {
        title = "The break has finished.",
        text = "Let's get that coding rolling!"
    },

    work = {
        title = "Pomodoro has finished.",
        test = "Time to take a break human!"
    },

}

function p:new()
  self.conf = conf
  self.status = {true, missing = self.conf.work}
  self.dialog = dialog

  self.widget = wibox.widget.textbox()
  self.timer  = timer{timeout = 1}
end

function p:set_time(t)
    if t >= self.conf.limit then
        t = os.date("%X", t - self.conf.limit)
    else
        t = os.date("%M:%S", t)
    end

    self.widget:set_text(string.format(" Pomodoro: %s", t))
end

function p:notify(dialog, duration, status)
    naughty.notify {
        bg = "#ff0000",
        fg = "#aaaaaa",
        title = dialog.title,
        text = dialog.text,
        timeout = 10, --in seconds
        height = 720, -- make it annoying
        width = 1280

    }

    self.status.missing = duration
    self.status[1] = status
    self.set_time(self, duration)
end

function p:set()
  self:new()
  self:set_time(self.conf.work)

  -- sets buttons
  self.widget:button(
    awful.util.table.join(
      awful.button({}, 1, function()
        self.last = os.time()
        self.timer:start()
      end),
      awful.button({}, 2, function()
        self.timer:stop()
      end),
      awful.button({}, 3, function()
        self.timer:stop()
        self.status.missing = self.conf.work
        self:set_time(self.conf.work)
      end)
    )
  )

  -- sets notification
  self.timer:connect_signal("timeout", function()
    local now = os.time()
    self.status.missing = self.status.missing - (now - self.last)
    self.last = now

    if self.status.missing > 0 then
      self:set_time(self.status.missing)
    else
      if self.status[1] then
        self:notify(self.dialog.work, self.conf.pause, false)
      else
        self:notify(self.dialog.pause, self.conf.work, true)
      end
      self.timer:stop()
    end
  end)
end


return pomodoro
