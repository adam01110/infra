--!nonstrict

local function cfg(key)
	return noctalia.getConfig(key)
end

local function render()
	barWidget.setGlyph(cfg("glyph"))
	if cfg("show_text") then
		barWidget.setText(cfg("text"))
	end
end

function onClick()
	noctalia.togglePanel("adam0/nix-monitor:panel")
end

render()
