-- avoid memory leak
collectgarbage('setpause', 100)
collectgarbage('setstepmul', 5000)

local cclog = function(...)
    print(string.format(...))
end

---------------

local winSize = CCDirector:sharedDirector():getWinSize()


Type = { EMPTY = 0, X = 1, O = 2 }

local function createPiece(type)
    return {
        type = type,
        sprite = CCSprite:spriteWithSpriteFrameName(type == Type.X and 'x.png' or 'o.png')
    }
end

local function createBoard()
    local boardLayer = CCLayer:node()
    local batchNode = CCSpriteBatchNode:batchNodeWithFile('tictactoe.pvr.gz')
    boardLayer:addChild(batchNode)

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile('tictactoe.plist')

    -- board
    local board = CCSprite:spriteWithSpriteFrameName('board.png')
    batchNode:addChild(board)
    board:setPosition(winSize.width / 2, winSize.height / 2)

    -- pieces
    pieces = {}
    local boardBounds = board:boundingBox()
    for i = 0, 5 do
        pieces[i] = createPiece(i < 3 and Type.X or Type.O)
        batchNode:addChild(pieces[i].sprite)
        local pieceSize = pieces[i].sprite:boundingBox().size
        local x = i < 3 and boardBounds.origin.x - pieceSize.width or boardBounds.origin.x + boardBounds.size.width + pieceSize.width
        local y = boardBounds.origin.y/2 + (i%3)*boardBounds.size.height/3 + boardBounds.size.height/6 + pieceSize.height/2
        pieces[i].sprite:setPosition( x, y )
    end

    -- handing touch events
    local function onTouchBegan(x, y)
        cclog("onTouchBegan: %0.2f, %0.2f", x, y)
        -- CCTOUCHBEGAN event must return true
        return true
    end

    local function onTouchMoved(x, y)
        cclog("onTouchMoved: %0.2f, %0.2f", x, y)
    end

    local function onTouchEnded(x, y)
        cclog("onTouchEnded")
    end

    local function onTouch(eventType, x, y)
        if eventType == CCTOUCHBEGAN then
            return onTouchBegan(x, y)
        elseif eventType == CCTOUCHMOVED then
            return onTouchMoved(x, y)
        else
            return onTouchEnded(x, y)
        end
    end

    boardLayer:registerScriptTouchHandler(onTouch)
    boardLayer:setIsTouchEnabled(true)

    return boardLayer
end

-- run
local sceneGame = CCScene:node()
sceneGame:addChild(createBoard())
CCDirector:sharedDirector():runWithScene(sceneGame)
