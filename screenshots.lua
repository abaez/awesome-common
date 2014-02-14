--- A quick little screenshot producer for awesome.
local picture_path = "$HOME/Pictures/Screenshots/awesome"

-- @export
return {
  capture = function()
    os.execute(string.format("import -window root %s/%s.png", picture_path,
       os.date("%F-%H%M%S")))
  end
}
