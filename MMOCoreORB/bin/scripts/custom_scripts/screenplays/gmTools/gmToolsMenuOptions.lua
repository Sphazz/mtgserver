gmToolsMenuOptions = {
	staff = {
		name = "Staff Tools",
		desc = "Staff tools description.",
		func = "openStaffWindow",
		callback = "staffWindowCallback",
		perms = {15, 14, 13},
		options = {
			testStaff01 = {
				name = "testStaff01",
				screen = "gmToolsCommandScreenplay", 
				func = "testStaff01",
				perms = {15, 14, 13},
			},
			testStaff02 = {
				name = "testStaff02",
				screen = "gmStaffScreenplay02", 
				func = "testStaff02",
				perms = {15, 14, 13},
			},
			testStaff03 = {
				name = "testStaff03",
				screen = "gmToolsCommandScreenplay", 
				func = "testStaff03",
				perms = {15, 14, 13},
			},
		},
	},
	event = {
		name = "Event Tools",
		desc = "Event tools description.",
		func = "openEventWindow",
		callback = "eventWindowCallback",
		perms = {15, 14, 13},
		options = {
			eventShuttle = {
				name = "Event Shuttle",
				screen = "eventShuttleNpcScreenplay", 
				func = "openEventTeleportNPCWindow",
				perms = {15, 14, 13, 12, 11, 10},
			},
			testEvent02 = {
				name = "testEvent02",
				screen = "gmToolsCommandScreenplay", 
				func = "testEvent02",
				perms = {15, 14, 13},
			},
		},
	},
	dev = {
		name = "Development Tools",
		desc = "Development tools description.",
		func = "openDevWindow",
		callback = "devWindowCallback",
		perms = {15, 14, 13},
		options = {
			testDev01 = {
				name = "testDev01",
				screen = "gmToolsCommandScreenplay", 
				func = "testDev01",
				perms = {15, 14, 13},
			},
			testDev02 = {
				name = "testDev02",
				screen = "gmToolsCommandScreenplay", 
				func = "testDev02",
				perms = {15, 14, 13},
			},
		},
	}
}