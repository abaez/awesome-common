local wibox = require("wibox")
local awful = require("awful")

-- pomodoro timer widget.
pomodoro = {}
local p = pomodoro
setmetatable(pomodoro, p)

-- tweak these values by minute to your liking.
p.duration = {
	pause = 5 *60,
	work = 35 *60
}

p.pause = {
	title = "Pause finished.",
	text = "DAMMIT, GET BACK TO WORK!"
}

p.work = {
	title = "Pomodoro finished.",
	text = "Time for a little break."
}

p.working = true
p.left = p.duration.work
p.widget = wibox.widget.textbox() -- widget({type = "textbox"})
p.timer = timer {timeout = 1}

function p:settime(t)
	-- if reaach over an hour set time to os.date
	local hr = 60^2

	if t >= hr then
		t = os.date("%X", t - hr)
	else
		t = os.date("%M:%S", t)
	end

	self.widget.text = string.format("Pomodoro: <b>%s</b>", t)
end

function p:notify(title, text, duration, working)
	naughty.notify {
		bg = "#ff0000",
		fg = "#aaaaaa",
		title = title,
		text = text,
		timeout = 10
	}

	p.left = duration
	p:settime(duration)
	p.working = working
end

p:settime(p.duration.work)

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
			p.left = p.duration.work:settime(p.duration.work)
		end)
	)
)

p.timer:connect_signal("timeout", function()
		local now = os.time()
		p.left = p.left - ( now - p.last)
		p.last = now

		if p.left > 0 then
			p:settime(p.left)
		else
			if p.working then
				p:notify(p.work.title, p.work.text, p.duration.pause, false)
			else
				p:notify(p.pause.title, p.pause.text, p.duration.work, true)
			end
			p.timer:stop()
		end
	end
)

return pomodoro