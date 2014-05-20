-- XML数据
local stateData = {
	shift = {"shift","die","stun","repel","attackCD","skill","attack","move","wait",},
	die = {"shift","die","stun","repel","attackCD","skill","attack","move","wait",},
	stun = {"shift","die","stun","attackCD","skill","attack","move","wait",},
	repel = {"shift","die","repel","attackCD","skill","attack","move","wait",},
	attackCD = {"shift","die","stun","repel","attackCD","skill","attack","move","wait",},
	skill = {"shift","die","stun","repel","attackCD","skill",},
	attack = {"shift","die","stun","repel","attackCD","attack",},
	move = {"shift","die","stun","repel","attackCD","skill","attack","move","wait",},
	wait = {"shift","die","stun","repel","attackCD","skill","attack","move","wait",},
}

print("LoadStateData -- Success")
return stateData
