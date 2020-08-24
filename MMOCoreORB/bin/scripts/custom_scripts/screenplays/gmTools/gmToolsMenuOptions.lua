gmToolsMenuOptions = {
	staff = {
		name = "Staff Tools",
		desc = "Staff tools description.",
		func = "openStaffWindow",
		callback = "staffWindowCallback",
		perms = {15, 14, 13, 12},
		options = {
			renameTarget = {
				name = "Rename Target",
				screen = "staffRenameScreenplay", 
				func = "openRenameObjectWindow",
				perms = {15, 14, 13, 12},
			},
		},
	},
	event = {
		name = "Event Tools",
		desc = "Event tools description.",
		func = "openEventWindow",
		callback = "eventWindowCallback",
		perms = {15, 14, 13, 12, 11, 10},
		options = {
			eventShuttle = {
				name = "Event Shuttle",
				screen = "eventShuttleNpcScreenplay", 
				func = "openEventTeleportNPCWindow",
				perms = {15, 14, 13, 12, 11, 10},
			},
			eventDungeon = {
				name = "Event Dungeon",
				screen = "eventDungeonScreenplay", 
				func = "openEventDungeonInitialWindow",
				perms = {15, 14, 13, 12, 11, 10},
			},
		},
	},
	dev = {
		name = "Development Tools",
		desc = "Development tools description.",
		func = "openDevWindow",
		callback = "devWindowCallback",
		perms = {15, 14},
		options = {
			reloadScreenplays = {
				name = "Reload Screenplays",
				screen = "devToolsGeneralScreenplay", 
				func = "reloadScreenplays",
				perms = {15, 14},
			},
		}
	}
}