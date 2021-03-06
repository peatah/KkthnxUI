local _, ns = ...
local oUF = ns.oUF or oUF
if not oUF then return end

-- Lua API
local ipairs = ipairs
local math_abs = math.abs
local math_max = math.max
local math_min = math.min
local pairs = pairs

-- Wow API
local GetFramerate = GetFramerate

local smoothing = {}
local function Smooth(self, value)
	if value ~= self:GetValue() or value == 0 then
		smoothing[self] = value
	else
		smoothing[self] = nil
	end
end

local function SmoothBar(bar)
	if not bar.SetValue_ then
		bar.SetValue_ = bar.SetValue
		bar.SetValue = Smooth
	end
end

local function ResetBar(bar)
	if bar.SetValue_ then
		bar.SetValue = bar.SetValue_
		bar.SetValue_ = nil
	end
end

local function hook(frame)
	if frame.Health then
		SmoothBar(frame.Health)
	end
	if frame.Power then
		SmoothBar(frame.Power)
	end
	if frame.AltPowerBar then
		SmoothBar(frame.AltPowerBar)
	end
end

for i, frame in ipairs(oUF.objects) do hook(frame) end
oUF:RegisterInitCallback(hook)

local f = CreateFrame('Frame')
f:SetScript('OnUpdate', function()
	local rate = GetFramerate()
	local limit = 30/rate

	for bar, value in pairs(smoothing) do
		local cur = bar:GetValue()
		local new = cur + math_min((value-cur)/3, math_max(value-cur, limit))
		if new ~= new then
			-- Mad hax to prevent QNAN.
			new = value
		end
		bar:SetValue_(new)
		if (cur == value or math_abs(new - value) < 2) and bar.Smooth then
			bar:SetValue_(value)
			smoothing[bar] = nil
		elseif not bar.Smooth then
			bar:SetValue_(value)
			smoothing[bar] = nil
		end
	end
end)