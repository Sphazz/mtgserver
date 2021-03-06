ruwan_tokai = Creature:new {
  objectName = "@mob/creature_names:sergeant_ruwan_tokai",
  socialGroup = "imperial",
  faction = "imperial",
  level = 100,
  chanceHit = 1.000000,
  damageMin = 645,
  damageMax = 1000,
  baseXp = 9336,
  baseHAM = 24000,
  baseHAMmax = 30000,
  armor = 0,
  resists = {0,0,0,0,0,0,0,0,-1},
  meatType = "",
  meatAmount = 0,
  hideType = "",
  hideAmount = 0,
  boneType = "",
  boneAmount = 0,
  milk = 0,
  tamingChance = 0.000000,
  ferocity = 0,
  pvpBitmask = NONE,
  creatureBitmask = NONE,
  optionsBitmask = AIENABLED + CONVERSABLE,
  diet = HERBIVORE,

  templates = {"object/mobile/dressed_ruwan_tokai.iff"},
  lootGroups = {},
  weapons = {},
  conversationTemplate = "ruwan_tokai_mission_giver_convotemplate",
  attacks = {}
}

CreatureTemplates:addCreatureTemplate(ruwan_tokai, "ruwan_tokai")
