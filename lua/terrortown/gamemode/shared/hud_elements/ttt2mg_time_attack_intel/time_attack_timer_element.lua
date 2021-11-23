local base = "pure_skin_element"

DEFINE_BASECLASS(base)

HUDELEMENT.Base = base

if CLIENT then
	local pad = 7
	local margin = 14

	local const_defaults = {
		basepos = {x = 0, y = 0},
		size = {w = 320, h = 40},
		minsize = {w = 150, h = 40}
	}

	function HUDELEMENT:PreInitialize()
		BaseClass.PreInitialize(self)

		local hud = huds.GetStored("pure_skin")
		if not hud then return end

		hud:ForceElement(self.id)
	end

	function HUDELEMENT:Initialize()
		self.scale = 1.0
		self.basecolor = self:GetHUDBasecolor()

		self.pad = pad
		self.margin = margin

		BaseClass.Initialize(self)
	end

	-- parameter overwrites
	function HUDELEMENT:IsResizable()
		return true, false
	end
	-- parameter overwrites end

	function HUDELEMENT:GetDefaults()
		const_defaults["basepos"] = {x = math.Round(ScrW() * 0.5 - self.size.w * 0.5), y = self.margin + 90 * self.scale}

		return const_defaults
	end

	function HUDELEMENT:PerformLayout()
		local defaults = self:GetDefaults()

		self.scale = math.min(self.size.w / defaults.minsize.w, self.size.h / defaults.minsize.h)
		self.basecolor = self:GetHUDBasecolor()
		self.pad = pad * self.scale

		BaseClass.PerformLayout(self)
	end

	function HUDELEMENT:ShouldDraw()
		local client = LocalPlayer()

		return IsValid(client)
	end

	function HUDELEMENT:Draw()
		local pos = self:GetPos()
		local size = self:GetSize()
		local x, y = pos.x, pos.y
		local w, h = size.w, size.h
		local progress = progress or 1
		local round_state = GAMEMODE.round_state

		if round_state ~= ROUND_ACTIVE then return end

		local color = Color(196, 56, 2,255)
		if not color then return end

		if timer.Exists("ttt2mg_time_attack_hud_timer") then

			progress = 1 - (CurTime() - GetGlobalInt("timer_start_time")) / GetGlobalInt("timer_dur_time")

			local secColor = util.ColorComplementary(color)
			local r = color.r - (color.r - secColor.r) * progress
			local g = color.g - (color.g - secColor.g) * progress
			local b = color.b - (color.b - secColor.b) * progress

			color = Color(r, g, b, 255)

			local timer_secs = timer.TimeLeft("ttt2mg_time_attack_hud_timer")

			local time = string.FormattedTime( timer_secs , "%02i:%02i")

			self:DrawBg(self.pos.x, self.pos.y, self.size.w, self.size.h, self.basecolor)

			-- draw bar
			self:DrawBar(x + pad, y + pad, w - pad * 2, h - pad * 2, color, progress, 1)

			self:DrawLines(x, y, w, h, self.basecolor.a)

			draw.AdvancedText(time, "PureSkinTimeLeft", x + 0.5 * w , y + 0.5 * h , COLOR_WHITE, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, true, self.scale)
		end
	end
end