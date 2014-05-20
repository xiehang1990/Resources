local talkData={}
talkData[1]={
				{
				role="1",
				content="come on baby",
				next=2,
				},
				{
				role="2",
				content="oh yeal",
				next=3,	
				},
				{
				role="1",
				content="客官马航是不是傻逼？",
				next=4,
				},
				{
				role="2",
				content="你这个还有疑问？你是不是傻逼",
				next=5,
				},
				{
				role="1",
				content="再说哥不理你了",
				next=6,
				},
				{
				role="1",
				content="是时候结束了撒",
				next=0,
				}
}

talkData[2]={
			{
			role="me",
			content="zhen jb",
			next=2,
			},
			{
			role="tanent",
			content="22oh yeal",
			next=3,	
			},
			{
			role="me",
			content="22客官马航是不是傻逼？",
			contentType={{3,5},{6,8}},
			next=4,
			},
			{
			role="me",
			num=3,
			content={
					"是",
					"不是",
					"不知道"
					},
			next={5,6,0}
			},
			{
			role="me",
			content="22再说哥不理你了",
			next=0,
			},
			{
			role="me",
			content="22是时候结束了撒",
			next=0,
			}
					
}

talkData[3]={

			{
			role="me",
			content="这是防守任务测试",
			next=2,
			},
			{
			role="tanent",
			content="防守任务号",
			next=0,	
			},
}

return talkData
					
					