devToolsGeneralScreenplay = ScreenPlay:new {
	scriptName = "devToolsGeneralScreenplay",
}

registerScreenPlay("devToolsGeneralScreenplay", false)

function devToolsGeneralScreenplay:reloadScreenplays(pPlayer)
	reloadScreenplaysLua(pPlayer)
end