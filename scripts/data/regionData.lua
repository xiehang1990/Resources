-- XML数据
local regionData = {
	aoLaiGuo = {
		requirement = {},
		sector = {
			aoLaiGuo1 = {
				requirement = {
					-- 解锁条件
				},
				style = "battle",
				group = "attacker",
				enemy = {
					formation = {
						{1,0,0},
						{2,0,0},
						{3,0,0},
					},
					fighterArray = {
						{
							roleID = "XiaoGuiHou",
							
							level = 10,
							strength = 10,
							intelligence = 10,
							physique = 10,

							skillArray = {
								"stun1",
								--"skillAttack2",
							},
						},
						{
							roleID = "HouTongLing",
						
							level = 11,
							strength = 10,
							intelligence = 10,
							physique = 10,

							skillArray = {
								"vampire1",
								"critical1",
								--"stun1",
							},
						},
						{
							roleID = "XiaoGuiHou",
						
							level = 10,
							strength = 10,
							intelligence = 10,
							physique = 10,

							skillArray = {
								--"rage1",
								"critical1",
								--"poison1",
								"vampire1",
								--"skillAttack3",
							},
						},						
					},
				},
				award = {
					-- 奖励
				},
			},
			aoLaiGuo2 = {
				requirement = {
					-- 解锁条件
				},
				style = explore,
				exploreTime = 60,
				enemy = {
					-- 敌人
				},
				award = {
					-- 奖励
				},
			},
		},
		tenaut = {
			monkey1,
			moneky2,
		}
	},
	
	huoYanShan = {
		requirement = {},
		sector = {
			huoYanShan1 = {
				requirement = {
					-- 解锁条件
				},
				style = battle,
				enemy = {
					-- 敌人
				},
				award = {
					-- 奖励
				},
			},
			huoYanShan2 = {
				requirement = {
					-- 解锁条件
				},
				style = explore,
				enemy = {
					-- 敌人
				},
				award = {
					-- 奖励
				},
			},
		},
		tenant = {
			tongZi1,
			tongZi2,
		},
	},
}

print("LoadRegionData -- Success")
return regionData