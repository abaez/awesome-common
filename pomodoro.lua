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

-- quick convert to seconds
local tosec = function(min) return min * 60 end

-- in minutes settings for pomodoro. use tosec to convert to seconds
p.conf = {
    pause   = tosec(5),
    work    = tosec(35),
    limit   = tosec(60) -- limit for call
}

p.status  = {
    true,
    missing = p.conf.work
}


p.dialog = {
    pause = {
        title = "The break has finished.",
        text = "Let's get that coding rolling!"
    },

    work = {
        title = "Pomodoro has finished.",
        test = "Time to take a break human!"
    }
}


p.widget = wibox.widget.textbox()
p.timer = timer {timeout = 1}


function p:set_time(t)
    if t >= self.conf.limit then
        t = os.date("%X", t - self.conf.limit)
    else
        t = os.date("%M:%S", t)
    end

    self.widget:set_text(string.format(" Pomodoro:%s", t))
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
    -- p:set_time(duration)
end


p:set_time(p.conf.work)
p.widget:buttons(
    awful.util.table.join(
        awful.button({}, 1, function()
            p.last = os.time()
            p.timer:start()
        end),
        awful.button({}, 2, function()
            p.timer:stop()
        end),
        awful.button({}, 3, function()
            p.timer:stop()
            p.status.missing = p.conf.work
            p:set_time(p.conf.work)
        end)
    )
)


p.timer:connect_signal("timeout", function()
    local now = os.time()
    p.status.missing = p.status.missing - (now - p.last)
    p.last = now

    if p.status.missing > 0 then
        p:set_time(p.status.missing)
    else
        if p.status[1] then
            p:notify(p.dialog.work, p.conf.pause, false)
        else
            p:notify(p.dialog.pause, p.conf.work, true)
        end
        p.timer:stop()
    end
end)


return pomodoro
