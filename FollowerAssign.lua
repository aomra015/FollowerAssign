-- Helper Functions --
local function buildingsWithFollowerSlot()
	local buildings = C_Garrison.GetBuildings()
	local buildingsWithSlot = {}

	for i, value in ipairs(buildings) do
		local hasFollowerSlot = select(17, C_Garrison.GetBuildingInfo(value.buildingID))
		if hasFollowerSlot then
			table.insert(buildingsWithSlot, value)
		end
	end

	return buildingsWithSlot
end

local function getAvailableFollowers(tbl)
	local availableFollowers = {}
	for i,value in ipairs(tbl) do
		if value.status == nil then
			table.insert(availableFollowers, value)
		end
	end

	return availableFollowers
end

local function levelSort(a, b)
	return a.level > b.level
end

local function highestLevelFollower(tbl)
	table.sort(tbl, levelSort)
	return tbl[1]
end

local function getBestFollower(followers)
	if #followers >= 1 then
		local availableFollowers = getAvailableFollowers(followers)
		if #availableFollowers == 1 then
			return availableFollowers[1]
		elseif #availableFollowers > 1 then
			return highestLevelFollower(availableFollowers)
		else
			return nil
		end
	end
end

local function getBuildingName(longName)
	local shortName = string.match(longName, "_%a+_")
	shortName = string.gsub(shortName, '_', '')
	return shortName
end

local function getFollowerInBuilding(building)
	return select(5, C_Garrison.GetFollowerInfoForBuilding(building.plotID))
end

local function addFollower(building, delay)
	-- skip if there is already a follower
	if getFollowerInBuilding(building) then
		return
	end

	local followers = C_Garrison.GetPossibleFollowersForBuilding(building.plotID)
	local bestFollower = getBestFollower(followers)

	if bestFollower then
		local function addFollowerToBuilding()
			C_Garrison.AssignFollowerToBuilding(building.plotID, bestFollower.followerID)
			print('|cffffcc00' .. bestFollower.name .. ' added to ' .. getBuildingName(building.texPrefix)  .. '|cffffcc00')
		end
		
		C_Timer.After(delay, addFollowerToBuilding)
	end
end

local function removeFollower(building, delay)
	local followerID = getFollowerInBuilding(building)

	if followerID then
		local follower = C_Garrison.GetFollowerInfo(followerID)
		local function removeFollowerFromBuilding()
			C_Garrison.RemoveFollowerFromBuilding(building.plotID, follower.followerID)
			print('|cffffcc00' .. follower.name .. ' removed from  ' .. getBuildingName(building.texPrefix) .. '|cffffcc00')
		end
		
		C_Timer.After(delay, removeFollowerFromBuilding)
	end
end

-- Main Functions --

local function assignFollowers(assign)
	local buildingsWithSlot = buildingsWithFollowerSlot()
	
	print('=== Starting to Assign Followers === ')
	local delay = 0
	for i,building in ipairs(buildingsWithSlot) do
		if assign == true then
			addFollower(building, delay)
			delay = delay + 0.5
		elseif assign == false then
			removeFollower(building, delay)
			delay = delay + 0.5
		end
	end

	C_Timer.After(delay, function()
		print('=== All done! === ')
	end)
	
end

local function createToggleButton()
	local ToggleFrame = CreateFrame("CheckButton", nil, GarrisonBuildingFrame, "InterfaceOptionsCheckButtonTemplate")
	ToggleFrame:SetSize(24, 24)
	ToggleFrame:SetHitRectInsets(0,0,0,0)
	ToggleFrame:SetPoint("LEFT", GarrisonBuildingFrame.BuildingList.MaterialFrame, 10, 30)
	ToggleFrame.Text:SetText("Followers assigned to buildings")
	ToggleFrame.Text:SetFontObject(GameFontHighlight)
	ToggleFrame:SetScript("OnClick", function(self)
		assignFollowers(self:GetChecked())
	end)
end


-- Set up Main Frame

local FollowerAssignFrame = CreateFrame("Frame", "FollowerAssignFrame", GarrisonBuildingFrame)
FollowerAssignFrame:RegisterEvent("GARRISON_ARCHITECT_OPENED")
FollowerAssignFrame:SetScript("OnEvent", createToggleButton)
