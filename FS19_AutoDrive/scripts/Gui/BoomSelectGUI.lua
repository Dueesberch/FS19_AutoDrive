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

function ADBoomSelectGui:onOpen()
    --g_logManager:info("ADBoomSelectGui:onOpen")
    self.booms = ADGraphManager:getMapBooms()
    for i in pairs(self.booms) do
        self.booms[i].state = ""
    end
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
    --g_logManager:info(self.autoDriveBoomSelectList:getSelectedElementIndex())
    if self.booms[self.autoDriveBoomSelectList:getSelectedElementIndex()].state == "" then
        self.booms[self.autoDriveBoomSelectList:getSelectedElementIndex()].state = "closed"
    else
        self.booms[self.autoDriveBoomSelectList:getSelectedElementIndex()].state = ""
    end
    self:refreshItems()
end

function ADBoomSelectGui:onClickBack()
    vehicle = g_currentMission.controlledVehicle
    ADBoomSelectGui:superClass().onClickBack(self)  -- TODO warum schließt die GUI nicht bei onClickOk()?
    for _, r in pairs(self.booms) do
        r.state = ""
    end
    vehicle.ad.stateModule:getCurrentMode():start()
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

function ADBoomSelectGui:onEnterPressed(_, isClick)
    if not isClick then
        --self:onClickOk()
    end
end

function ADBoomSelectGui:onEscPressed()
    self:onClickBack()
end
