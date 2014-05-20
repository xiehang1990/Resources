-- XML数据
local skillData = {
	accuracy1 = {
		needInvoke = false,
		needPause = false,
		trigger = {
			mode = "always",
			condition = "beforeAttack",
		},
		{
			skillName = "accuracy",			
			parameter = {
				ratio = 0.5,
			},
		},
	},

	rage1 = {
		needInvoke = true,
		needPause = false,
		trigger = {
			mode = "attackCount",
			count = 5,
			condition = "beforeFrame",
		},
		{
			skillName = "rage",	
			buff = {
				buffName = "changeAttackSpeed",
				unique = true,
				uniqueNumber = 1,
				needRender = "rage",
				counter = {
					mode = "frame",
					lastFrame = 200,
				},
				trigger = {
					mode = "always",
				},
				parameter = {
					ratio = 1,
				},			
			},
		},
	},

	vampire1 = {
		needInvoke = false,
		needPause = false,
		trigger = {
			mode = "always",
			condition = "onDamageApply",
		},
		{
			skillName = "vampire",			
			parameter = {
				ratio = 0.2,
			},	
		},
		
	},

	killVampire1 = {
		needInvoke = false,
		needPause = false,
		trigger = {
			mode = "always",
			condition = "onKillTarget",
		},
		{
			skillName = "killVampire",
			parameter = {
				ratio = 0.2,
			},
		},
	},

	poison1 = {
		needInvoke = false,
		needPause = false,
		trigger = {
			mode = "ratio",
			ratio = 1,
			condition = "beforeAttack",
		},
		{
			skillName = "poison",
			buff = {
				buffName = "poison",
				unique = true,
				uniqueNumber = 1,
				needRender = "poison",
				counter = {
					mode = "frame",
					lastFrame = 200,
				},
				trigger = {
					mode = "frameCount",
					count = 10,
				},
				parameter = {
					type = "skill",
					value = 5,
				},
			},
		},
	},

	dodge1 = {
		needInvoke = false,
		needPause = false,
		trigger = {
			mode = "always",
			condition = "beforeDamage",
		},
		{
			skillName = "dodge",			
			parameter = {
				ratio = 0.5,
			},			
		},
	},

	critical1 = {
		needInvoke = false,
		needPause = false,
		trigger = {
			mode = "ratio",
			ratio = 0.3,
			condition = "beforeAttack",
		},
		{
			skillName = "critical",			
			parameter = {
				factor = 1.5,
			},			
		},
	},

	stun1 = {
		needInvoke = false,
		needPause = false,
		trigger = {
			mode = "attackCount",
			count = 5,
			condition = "beforeAttack",
		},
		{
			skillName = "stun",			
			buff = {
				buffName = "stun",
				unique = true,
				uniqueNumber = 1,
				needRender = false,
				counter = {
					mode = "frame",
					lastFrame = 20,
				},
				trigger = {
					mode = "always"
				},
			},
		},
	},

	repel1 = {
		needInvoke = true,
		needPause = false,
		trigger = {
			mode = "attackCount",
			count = 1,
			condition = "beforeFrame",
		},
		{
			skillName = "repel",
			buff = {
				buffName = "repel",
				unique = true,
				uniqueNumber = 1,
				needRender = false,
				counter = {
					mode = "once",
					done = false,
				},
				trigger = {
					mode = "once",
					done = false,
				},
				parameter = {
					length = 100,
					height = 80,
					time = 15,
				},				
			},
		},
	},

	addTotalHP1 = {
		needInvoke = false,
		needPause = false,
		trigger = {
			mode = "always",
			condition = "beforeFrame"
		},
		{
			skillName = "changeTotalHP",
			parameter = {
				ratio = 0.1,
			},
		},
	},

	skillAttack1 = {
		needInvoke = true,
		needPause = true,
		trigger = {
			mode = "attackCount",
			count = 3,
			condition = "beforeFrame",
		},
		{
			skillName = "skillAttack",
			parameter = {
				weaponStyle = "short",
				area = false,
				areaRange = 0,
				bulletName = "",
				skillDamage = 100,
				range = 0,
				buff = {
					{
						buffName = "repel",
						unique = true,
						uniqueNumber = 1,
						needRender = false,
						counter = {
							mode = "once",
							done = false,
						},
						trigger = {
							mode = "once",
							done = false,
						},
						parameter = {
							length = 200,
							height = 80,
							time = 15,
						},	
					},
				},
			},
		},
	},

	skillAttack2 = {
		needInvoke = true,
		needPause = true,
		trigger = {
			mode = "attackCount",
			count = 5,
			condition = "beforeFrame",
		},
		{
			skillName = "skillAttack",
			parameter = {
				weaponStyle = "short",
				area = true,
				areaRange = 200,
				bulletName = "",
				skillDamage = 100,
				range = 0,
				buff = {
					{
						buffName = "repel",
						unique = true,
						uniqueNumber = 1,
						needRender = false,
						counter = {
							mode = "once",
							done = false,
						},
						trigger = {
							mode = "once",
							done = false,
						},
						parameter = {
							length = 200,
							height = 80,
							time = 30,
						},	
					},
				},
			},
		},
	},

	skillAttack3 = {
		needInvoke = true,
		needPause = true,
		trigger = {
			mode = "attackCount",
			count = 4,
			condition = "beforeFrame",
		},
		{
			skillName = "skillAttack",
			parameter = {
				weaponStyle = "long",
				area = false,
				areaRange = 0,
				bulletName = "banyuezhan",
				skillDamage = 100,
				range = 150,
				buff = {
					{
						buffName = "repel",
						unique = true,
						uniqueNumber = 1,
						needRender = false,
						counter = {
							mode = "once",
							done = false,
						},
						trigger = {
							mode = "once",
							done = false,
						},
						parameter = {
							length = 120,
							height = 0,
							time = 10,
						},	
					},
				},
			},
		},
	},

	banyuezhan = {
		needInvoke = true,
		needPause = true,
		trigger = {
			mode = "attackCount",
			count = 5,
			condition = "beforeFrame",
		},
		{
			skillName = "skillAttack",
			parameter = {
				weaponStyle = "long",
				area = false,
				areaRange = 0,
				bulletName = "banyuezhan",
				skillDamage = 200,
				range = 150,
				buff = {},
			},
		},
	},

	WanJianJue = {
		needInvoke = true,
		needPause = true,
		trigger = {
			mode = "attackCount",
			count = 3,
			condition = "beforeFrame",
		},
		{
			skillName = "damageEffectSource",
			buff = {
				buffName = "damageEffectSource",
				unique = true,
				uniqueNumber = 1,
				needRender = false,
				counter = {
					mode = "frame",
					lastFrame = 50,
				},
				trigger = {
					mode = "frameCount",
					count = 10,
				},
				parameter = {
					-- targetMode为floor则在当前层寻找目标，如果targetMode为hotel则在所有敌人间寻找目标
					targetMode = "hotel",
					buff = {
						buffName = "damageEffect",
						unique = true,
						uniqueNumber = 1,
						needRender = false,
						counter = {
							mode = "once",
							done = false,
						},
						trigger = {
							mode = "once",
							done = false,
						},
						parameter = {
							value = 15,
							type = "skill",
							effectName = "WanJianJue",
						},
					},
				},
			},
		},
	},
}
	
print("LoadSkillData -- Success")
return skillData