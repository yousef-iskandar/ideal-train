---Common Utilities
--@class Utilities
--@author yousef
local Utilities = {}

--- Recursively copy a table and all its contents.
-- @param original the table to copy
-- @return a copy of the table
function Utilities.deepCopy(original)
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			v = Utilities.deepCopy(v)
		end
		copy[k] = v
	end
	return copy
end

return Utilities
