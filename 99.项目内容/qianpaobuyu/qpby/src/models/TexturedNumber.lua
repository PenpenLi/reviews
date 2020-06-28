local TexturedNumber = class("TexturedNumber", cc.Node)
function TexturedNumber:ctor()
    self:setCascadeOpacityEnabled(true)
    self.__textureSet = {}
    self.__currentNumber = 0
    self.__workingSprites = {size = 0}
    self.__usedSize = 0
    self.__hasTexture = false
    self.__willSeperate = true
    self.__limitTrigger = 0
    self.__spriteContainer = cc.Node:create()
    self.__spriteContainer:setCascadeOpacityEnabled(true)
    self:addChild(self.__spriteContainer)
    self.defaultSizeFix = {0, 0}
    self.defaultPositionFix = {0, 0}
    self._splited = {}
end
function TexturedNumber:setTextureSet(textureSet)
    self.__textureSet = textureSet
    self:doLayout()
end
function TexturedNumber:setLimitTrigger(limitTrigger)
    self.__limitTrigger = limitTrigger
end
function TexturedNumber:ensureWorkingCapacity(capacity)
    if self.__workingSprites.size < capacity then
        for i = self.__workingSprites.size + 1, capacity do
            if self.__textureSet.textureType == 1 then
                self.__workingSprites[i] = cc.Sprite:create()
                if cc.Node.setCullFace then
                    self.__workingSprites[i]:setCullFace(true)
                end
            elseif self.__textureSet.textureType == 2 then
                self.__workingSprites[i] =
                    sp.SkeletonAnimation:create(self.__textureSet.jsonFileName, self.__textureSet.atlasFileName)
            else
                assert(false)
            end
            self.__workingSprites[i]:setVisible(false)
            self.__workingSprites[i]:setCascadeOpacityEnabled(true)
            self.__spriteContainer:addChild(self.__workingSprites[i])
        end
        self.__workingSprites.size = capacity
    end
end
function TexturedNumber:setNumber(number)
    self.__currentNumber = number
    self:doLayout()
end
function TexturedNumber:split(number)
    number = tonumber(number)
    number = number and number or 0
    return self:splitNumber(number)
end
function TexturedNumber:splitNumber(number)
    local size = 1
    splited = self._splited
    if self.__useUnit and number >= self.__limitTrigger then
        if math.floor(number / 100000000) > 0 then
            splited[size] = "y"
            size = size + 1
            number = number / 100000000
        end
        if math.floor(number / 10000) > 0 then
            splited[size] = "w"
            size = size + 1
            number = number / 10000
        end
    end
    splited[size] = math.floor(number % 10)
    size = size + 1
    number = math.floor(number / 10)
    while number > 0 do
        if self.__willSeperate and math.floor(size % 4) == 0 then
            splited[size] = ","
            size = size + 1
        end
        splited[size] = math.floor(number % 10)
        size = size + 1
        number = math.floor(number / 10)
    end
    splited.size = size - 1
    return splited
end
function TexturedNumber:doLayout()
    local splited = self:split(self.__currentNumber)
    self:ensureWorkingCapacity(splited.size)
    for i = 1, self.__workingSprites.size do
        self.__workingSprites[i]:setVisible(false)
    end
    local maxHeight = 0
    local currentWidth = 0
    for i = splited.size, 1, -1 do
        if not self.__textureSet[splited[i]] then
            splited[i] = ","
        end
        local texture = self.__textureSet[splited[i]].texture or ""
        local sizeFix = self.__textureSet[splited[i]].sizeFix or self.defaultSizeFix
        local positionFix = self.__textureSet[splited[i]].positionFix or self.defaultPositionFix
        local currentSprite = self.__workingSprites[i]
        local spriteSize = currentSprite:getContentSize()
        currentSprite:setVisible(true)
        if self.__textureSet.textureType == 1 then
            currentSprite:setTexture(texture)
            spriteSize = currentSprite:getContentSize()
        elseif self.__textureSet.textureType == 2 then
            spriteSize = cc.size(self.__textureSet.textureWidth, self.__textureSet.textureHeight)
            currentSprite:setSkin(texture)
        else
            assert(false)
        end
        spriteSize.width = spriteSize.width + sizeFix[1]
        spriteSize.height = spriteSize.height + sizeFix[2]
        if spriteSize.height > maxHeight then
            maxHeight = spriteSize.height
        end
        currentSprite:setPosition(currentWidth + spriteSize.width / 2 + positionFix[1], maxHeight / 2 + positionFix[2])
        currentWidth = currentWidth + spriteSize.width
    end
    self:setContentSize(cc.size(currentWidth, maxHeight))
    self.__usedSize = splited.size
end
function TexturedNumber:enableSeperator()
    self.__willSeperate = true
end
function TexturedNumber:disableSeperator()
    self.__willSeperate = false
end
function TexturedNumber:enableUnit()
    self.__useUnit = true
end
function TexturedNumber:disableUnit()
    self.__useUnit = false
end
function TexturedNumber:onDestroy()
    self.__textureSet = nil
    for i = 1, self.__workingSprites.size do
        self.__workingSprites[i]:removeFromParent()
        self.__workingSprites[i] = nil
    end
    self.__workingSprites = nil
    self.__spriteContainer:removeFromParent()
    self.__spriteContainer = nil
    self.defaultSizeFix = nil
    self.defaultPositionFix = nil
    self._splited = nil
end
return TexturedNumber
