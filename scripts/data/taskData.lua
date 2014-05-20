local taskData = {}

taskData[1]={	
				tenantID="10000",
				talkID=1,
				reward={
							BasicReward={
											gold=1111,
											prestige=10
							},
							TenantReward={
								experience=100,
								tenantID="10000"
							},

					},
				type="ArticleTask",
				
				article=
					{
						{
							id="XiGua",
							name="西瓜",
							description="这是一种水果",
							num=5,
							judge=false
						},
						{
							id="PanTao",
							name="蟠桃",
							description="这个智痔疮",
							num=2,
							judge=false
						},

					},
				title="收集水果",
				description="我有点饿了，能不能给\n点水果吃呢"		
			}

taskData[2]=
			{	
				tenantID="10001",
				talkID=2,
				reward={
							BasicReward={
											gold=2222,
											prestige=10
										}
						},
				type="ArticleTask",
				
				article=
					{
						{
							id="ZhuSun",
							name="竹笋",
							description="这是一种植物",
							num=1,
							judge=false 
						},
					},
				title="聊天",
				description="想要花果山的竹笋，吱吱"
			}



taskData[3]=			
			{
							tenantID="10002",
							talkID=3,
							type="DefenceTask",
							reward ={
										BasicReward={
											gold=6,
											prestige=1
										},
										StorageReward={
											{
											id="ZhuSun",
											num=10
											}

										}

								},
							battleData="没有",
							talk={},
							condition={
										BasicCondition={
															gold=3000	
														}

										},
							title="防守",
							description="帮我抵挡牛魔王的报复"
			}


return taskData



