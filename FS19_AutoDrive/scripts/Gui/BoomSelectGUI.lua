ADBoomSelectGui = {}
ADBoomSelectGui.CONTROLS = {"textInputElement", "listItemTemplate", "autoDriveBoomSelectList"}

local ADBoomSelectGui_mt = Class(ADBoomSelectGui, ScreenElement)

function ADBoomSelectGui:new(target)
	local o = ScreenElement:new(target, ADBoomSelectGui_mt)
	o.returnScreenName = ""
	o.booms = {}
	o:registerControls(ADBoomSelectGui.CONTROLS)
	return o
end

function ADBoomSelectGui:onCreate()
	self.listItemTemplate:unlinkElement()
	self.listItemTemplate:setVisible(false)
end

function ADBoomSelectGui:initBooms()
	vehicle = g_currentMission.controlledVehicle
	self.booms = ADGraphManager:getMapBooms()
	
	if #self.booms == 0 then
		ADBoomSelectGui:superClass().onClickBack(self)
		vehicle.ad.stateModule:getCurrentMode():start()
	end

	local defaults = vehicle.ad.stateModule:getDefaultBooms()
	for j, r in pairs(self.booms) do
		local found
		for _, i in pairs(defaults) do
			if r.name == i then
				found = true
				break
			else
				found = false
			end
		end
		if found == true then
			self.booms[j].state = "closed"
		else
			self.booms[j].state = ""
		end
	end
end

function ADBoomSelectGui:onOpen()
	self:initBooms()
	self:refreshItems()
	ADBoomSelectGui:superClass().onOpen(self)
end

function ADBoomSelectGui:refreshItems()
	self.autoDriveBoomSelectList:deleteListItems()
	for _, r in pairs(self.booms) do
		local new = self.listItemTemplate:clone(self.autoDriveBoomSelectList)
		new:setVisible(true)
		new.elements[1]:setText(r.name)
		new.elements[2]:setText(r.state)
		new:updateAbsolutePosition()
	end
end

function ADBoomSelectGui:onListSelectionChanged(rowIndex)
end

function ADBoomSelectGui:onDoubleClick(rowIndex)
	if self.booms[self.autoDriveBoomSelectList:getSelectedElementIndex()].state == "" then
		self.booms[self.autoDriveBoomSelectList:getSelectedElementIndex()].state = "closed"
	else
		self.booms[self.autoDriveBoomSelectList:getSelectedElementIndex()].state = ""
	end
	self:refreshItems()
end

function ADBoomSelectGui:onClickBack()
	for _, r in pairs(self.booms) do
		r.state = ""
	end
	self:refreshItems()
end

function ADBoomSelectGui:onClickOk()
	vehicle = g_currentMission.controlledVehicle
	ADBoomSelectGui:superClass().onClickBack(self)
	-- remove outgoing from boom vehicle waypoint
	for _, r in pairs(self.booms) do
		if r.state == "closed" then
				for i=1, #vehicle.ad.wayPoints[r.id].out do
					for j=1, #vehicle.ad.wayPoints[vehicle.ad.wayPoints[r.id].out[i]].incoming do
						if vehicle.ad.wayPoints[vehicle.ad.wayPoints[r.id].out[i]].incoming[j] == r.id then
							vehicle.ad.wayPoints[vehicle.ad.wayPoints[r.id].out[i]].incoming[j] = nil
						end
					end
					vehicle.ad.wayPoints[r.id].out[i] = nil
				end
		end
	end
	vehicle.ad.stateModule:getCurrentMode():start()
end

function ADBoomSelectGui:onClickCancel()
	-- save
	vehicle = g_currentMission.controlledVehicle
	--ADBoomSelectGui:superClass().onClickCancel(self)
	ADBoomSelectGui:superClass().onClickBack(self)
	defaults = {}
	count = 1
	for _, r in pairs(self.booms) do
		if r.state == "closed" then
			defaults[count] = r.name
			count = count + 1
		end
	end
	vehicle.ad.stateModule:setDefaultBooms(defaults)
end

function ADBoomSelectGui:onClickActivate()
	-- load
	ADBoomSelectGui:superClass().onClickActivate(self)
	self:initBooms()
	self:refreshItems()
end

function ADBoomSelectGui:onEnterPressed(_, isClick)
	if not isClick then
		--self:onClickOk()
	end
end

function ADBoomSelectGui:onEscPressed()
	self:onClickBack()
end
