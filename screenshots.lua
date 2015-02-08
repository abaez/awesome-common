--- A quick little screenshot producer for awesome.
-- @author [Alejandro Baez](https://twitter.com/a_baez)
-- @copyright 2015
-- @license MIT (see @{LICENSE})
-- @module screenshot

local picture_path = "$HOME/Pictures/Screenshots/awesome"

-- @export
return {
  capture = function()
    os.execute(string.format("import -window root %s/%s.png", picture_path,
                             os.date("%F-%H%M%S")))
  end
}
