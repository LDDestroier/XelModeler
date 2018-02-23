local scr_x, scr_y = term.getSize()

local keysDown, miceDown = {}, {}

local path = fs.getDir(shell.getRunningProgram())
local APIpath = fs.combine(path,"API")
local modelDir = fs.combine(path,"models")

os.loadAPI(fs.combine(APIpath,"ThreeD"))
os.loadAPI(fs.combine(APIpath,"bufferAPI"))
os.loadAPI(fs.combine(APIpath,"blittle"))

local objects = {}

local camera = {
	x = 4,
	y = 0,
	z = 4,
	lookZ = 45,
	lookY = 0,
	moveSpeed = 0.25,
	turnSpeed = 5,
	useBLittle = true
}

local control = {
	moveUp = keys.e,
	moveDown = keys.q,
	moveForward = keys.w,
	moveBackwards = keys.s,
	moveLeft = keys.a,
	moveRight = keys.d,
	lookUp = keys.up,
	lookDown = keys.down,
	lookLeft = keys.left,
	lookRight = keys.right
}

local backgroundColors = {
	sky = colors.white,
	ground = colors.black,
}

local movementTick = function()
	if keysDown[control.moveUp] then
		camera.y = camera.y + camera.moveSpeed
	end
	if keysDown[control.moveDown] then
		camera.y = camera.y - camera.moveSpeed
	end
	if keysDown[control.moveForward] then
		camera.x = camera.x + (math.cos(math.rad(camera.lookZ)) * camera.moveSpeed)
		camera.z = camera.z + (math.sin(math.rad(camera.lookZ)) * camera.moveSpeed)
	end
	if keysDown[control.moveBackwards] then
		camera.x = camera.x - (math.cos(math.rad(camera.lookZ)) * camera.moveSpeed)
		camera.z = camera.z - (math.sin(math.rad(camera.lookZ)) * camera.moveSpeed)
	end
	if keysDown[control.moveLeft] then
		camera.x = camera.x + math.cos(math.rad(camera.lookZ - 90)) * camera.moveSpeed
		camera.z = camera.z + math.sin(math.rad(camera.lookZ - 90)) * camera.moveSpeed
	end
	if keysDown[control.moveRight] then
		camera.x = camera.x + math.cos(math.rad(camera.lookZ + 90)) * camera.moveSpeed
		camera.z = camera.z + math.sin(math.rad(camera.lookZ + 90)) * camera.moveSpeed
	end
	if keysDown[control.lookDown] then
		camera.lookY = (camera.lookY - camera.turnSpeed) % 360
	end
	if keysDown[control.lookUp] then
		camera.lookY = (camera.lookY + camera.turnSpeed) % 360
	end
	if keysDown[control.lookLeft] then
		camera.lookZ = (camera.lookZ - camera.turnSpeed) % 360
	end
	if keysDown[control.lookRight] then
		camera.lookZ = (camera.lookZ + camera.turnSpeed) % 360
	end
end

local getInput = function() --loops
	local evt, butt, x, y
	while true do
		evt, butt, x, y = os.pullEvent()
		if evt == "key" then
			keysDown[butt] = true
		elseif evt == "key_up" then
			keysDown[butt] = nil
		elseif evt == "mouse_click" or evt == "mouse_drag" then
			miceDown[butt] = {x=x,y=y}
		elseif evt == "mouse_up" then
			miceDown[butt] = nil
		end
	end
end

local frame = ThreeD.newFrame(1,1,scr_x,scr_y,90,camera.x,camera.y,camera.z,camera.lookZ,camera.lookY,backgroundColors.ground,modelDir)
frame:useBLittle(camera.useBLittle)

local render = function() --loops
	while true do
		movementTick()
		frame:setCamera(camera.x, camera.y, camera.z, camera.lookZ, camera.lookY)
		frame:loadGround(backgroundColors.ground)
		frame:loadSky(backgroundColors.sky)
		frame:loadObjects(objects)
		frame:drawBuffer()
		os.queueEvent("queue")
		os.pullEvent("queue")
	end
end



local startItAll = function()
	parallel.waitForAny(getInput, render)
end

local tArg = {...}

if tArg[1] then
	if fs.exists(fs.combine(modelDir,tArg[1])) then
		objects[#objects+1] = {model=tArg[1],x=0,y=0,z=0,rotationY=0}
	end
end

startItAll()
