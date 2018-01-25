local AnimBatch = class(Node)
local Easing = require('core.ex.easing')

function AnimBatch:ctor(pintu, path)
	self.m_pinTu = pintu;
	self.m_vertex = {}
	self.m_index = {}
	self.m_texcoord = {}
	self.m_boxInfo = {}
	self.m_animation = {}
	self.m_bindData = {}
	self.m_vertexId = res_alloc_id()
	self.m_indexId = res_alloc_id()
	self.m_textureId = res_alloc_id()
	self.m_texcoordId = res_alloc_id()

    res_create_image(0, self.m_textureId, path, 0, 1)

	res_create_double_array(0, self.m_vertexId, self.m_vertex)
	res_create_ushort_array(0, self.m_indexId, self.m_index)
	res_create_double_array(0, self.m_texcoordId, self.m_texcoord)

	drawing_set_node_renderable(self.m_drawingID, 0x0007, 0x40)
    drawing_set_node_vertex(self.m_drawingID, self.m_vertexId, self.m_indexId)
    drawing_set_node_texture(self.m_drawingID, self.m_textureId, self.m_texcoordId)

    local timeoutAnim = self:addPropTranslate(2, kAnimRepeat, 0, 0, 0, 0, 0, 0)
    timeoutAnim:setEvent(self, AnimBatch.run)

end

function AnimBatch:dtor()
    res_delete(self.m_vertexId)
    res_delete(self.m_indexId)
    res_delete(self.m_textureId)
    res_delete(self.m_texcoordId)
end

function AnimBatch:bind(index, data)
    self.m_bindData[index] = data
end

function AnimBatch:getBindData(index)
    return self.m_bindData[index]
end

function AnimBatch:count()
    return #self.m_vertex / 12
end

function AnimBatch:add(texture, x, y, update)
    local texturex = texture and self.m_pinTu[texture].x or 0
    local texturey = texture and self.m_pinTu[texture].y or 0
    local texturew = texture and self.m_pinTu[texture].width or 0
    local textureh = texture and self.m_pinTu[texture].height or 0

    x = x * System.getLayoutScale()
    y = y * System.getLayoutScale()
    w = texturew * System.getLayoutScale()
    h = textureh * System.getLayoutScale()

    table.insert(self.m_vertex, x);
    table.insert(self.m_vertex, y);
    table.insert(self.m_vertex, 0);
    table.insert(self.m_vertex, w + x);
    table.insert(self.m_vertex, y);
    table.insert(self.m_vertex, 0);
    table.insert(self.m_vertex, w + x);
    table.insert(self.m_vertex, h + y);
    table.insert(self.m_vertex, 0);
    table.insert(self.m_vertex, x);
    table.insert(self.m_vertex, h + y);
    table.insert(self.m_vertex, 0);

    table.insert(self.m_boxInfo, {x = x, y = y, width = w, height = h})

    local index = math.floor(#self.m_index / 6);
    table.insert(self.m_index, index * 4 );
    table.insert(self.m_index, index * 4 + 1);
    table.insert(self.m_index, index * 4 + 2);
    table.insert(self.m_index, index * 4 );
    table.insert(self.m_index, index * 4 + 2);
    table.insert(self.m_index, index * 4 + 3);

    local width  = res_get_image_width(self.m_textureId);
    local height = res_get_image_height(self.m_textureId);

    table.insert(self.m_texcoord, texturex  / width);
    table.insert(self.m_texcoord, texturey  / height);
    table.insert(self.m_texcoord, (texturex + texturew) / width);
    table.insert(self.m_texcoord, texturey  / height);
    table.insert(self.m_texcoord, (texturex + texturew) / width);
    table.insert(self.m_texcoord, (texturey + textureh)/ height);
    table.insert(self.m_texcoord, texturex  / width);
    table.insert(self.m_texcoord, (texturey + textureh)/ height);

    if update then
	    res_set_double_array(self.m_vertexId, self.m_vertex);
	    res_set_ushort_array(self.m_indexId, self.m_index);
	    res_set_double_array(self.m_texcoordId, self.m_texcoord);
	end
    
    return #self.m_vertex / 12
end

function AnimBatch:move(index, duration, delay, easingx, easingy, fromX, fromY, toX, toY, obj, callback)
    if not index or index > #self.m_vertex / 12 then
        return
    end
    
    fromX = fromX * System.getLayoutScale()
    fromY = fromY * System.getLayoutScale()
    toX = toX * System.getLayoutScale()
    toY = toY * System.getLayoutScale()

    local anim = {}
    anim.stime = os.clock() * 1000 + delay
    anim.etime = anim.stime + duration
    anim.duration = duration
    anim.delay = delay
    anim.easingx = easingx
    anim.easingy = easingy
    anim.fromX = fromX
    anim.fromY = fromY
    anim.toX = toX
    anim.toY = toY
    anim.obj = obj
    anim.callback = callback

    self.m_animation[index] = anim
end

function AnimBatch:rotate(index, easingAngle, fromAngle, toAngle)
    if not index or index > #self.m_vertex / 12 then
        return
    end

    if self.m_animation[index] then
        self.m_animation[index].easingAngle = easingAngle
        self.m_animation[index].fromAngle = fromAngle
        self.m_animation[index].toAngle = toAngle
    end
end

function AnimBatch:scale(index, easingScale, fromScale, toScale)
    if not index or index > #self.m_vertex / 12 then
        return
    end

    if self.m_animation[index] then
        self.m_animation[index].easingScale = easingScale
        self.m_animation[index].fromScale = fromScale
        self.m_animation[index].toScale = toScale
    end
end

function AnimBatch:setVertex(index, px, py, pangle, pscale)
    local width = self.m_boxInfo[index].width
	local height = self.m_boxInfo[index].height
    
    local x = px or 0
    local y = py or 0
    local angle = pangle or 0
    local scale = pscale or 1
    
	self.m_boxInfo[index].x = x
	self.m_boxInfo[index].y = y

	local index = (index - 1) * 12
	
	local halfW = width/2 * scale
	local halfH = height/2 * scale

	local rada = math.rad(angle);
	local cosa = math.cos(rada);
	local sina = math.sin(rada);

	local centerX = x + halfW
	local centerY = y + halfH

	self.m_vertex[index + 1] = centerX + ((-halfW) * cosa - (-halfH) * sina)
	self.m_vertex[index + 2] = centerY + ((-halfW) * sina + (-halfH) * cosa)
	self.m_vertex[index + 3] = 0
	self.m_vertex[index + 4] = centerX + (halfW * cosa - (-halfH) * sina)
	self.m_vertex[index + 5] = centerY + (halfW * sina + (-halfH) * cosa)
	self.m_vertex[index + 6] = 0
	self.m_vertex[index + 7] = centerX + (halfW * cosa - halfH * sina)
	self.m_vertex[index + 8] = centerY + (halfW * sina + halfH * cosa)
	self.m_vertex[index + 9] = 0
	self.m_vertex[index + 10] = centerX + ((-halfW) * cosa - halfH * sina)
	self.m_vertex[index + 11] = centerY + ((-halfW) * sina + halfH * cosa)
	self.m_vertex[index + 12] = 0
end

function AnimBatch:getVertex(index)
	-- body

	return 	self.m_boxInfo[index].x 	 / System.getLayoutScale(), 
			self.m_boxInfo[index].y 	 / System.getLayoutScale(), 
			self.m_boxInfo[index].width  / System.getLayoutScale(), 
			self.m_boxInfo[index].height / System.getLayoutScale()
end

function AnimBatch:getTexture(texture)
	return self.m_pinTu[texture]
end

function AnimBatch:updateVertex()
	-- body
	res_set_double_array(self.m_vertexId, self.m_vertex);
end

function AnimBatch:updateTexCoord()
	-- body
	 res_set_double_array(self.m_texcoordId, self.m_texcoord);
end
function AnimBatch:updateIndex()
	-- body
	res_set_ushort_array(self.m_indexId, self.m_index);
end

function AnimBatch:update()
	self:updateVertex()
	self:updateIndex()
	self:updateTexCoord()
end

function AnimBatch:clear()
	-- body
	self.m_vertex 	= {};
	self.m_index 	= {};
	self.m_texcoord = {};
	self.m_animation = {};
	self.m_bindData  = {};
	self.m_boxInfo 	= {}

	res_set_double_array(self.m_vertexId, self.m_vertex);
    res_set_ushort_array(self.m_indexId, self.m_index);
    res_set_double_array(self.m_texcoordId, self.m_texcoord);
end

function AnimBatch:run()
    local rm = {}
    local update = false
    local now = os.clock() * 1000

    for k, v in pairs(self.m_animation) do
        if now > v.stime then
            local endtime = math.min(now, v.etime)
            local x  = v.easingx and Easing.fns[v.easingx](endtime - v.stime, v.fromX, v.toX - v.fromX, v.duration) or nil
			local y  = v.easingy and Easing.fns[v.easingy](endtime - v.stime, v.fromY, v.toY - v.fromY, v.duration) or nil
            local a = v.easingAngle and Easing.fns[v.easingAngle](endtime - v.stime, v.fromAngle, v.toAngle - v.fromAngle, v.duration) or nil
            local s = v.easingScale and Easing.fns[v.easingScale](endtime - v.stime, v.fromScale, v.toScale - v.fromScale, v.duration) or nil
            self:setVertex(k, x, y, a, s)
            if not update then
                update = true
            end     
            if now >= v.etime then
				table.insert(rm, k)
				if v.callback then
					v.callback(v.obj)
				end
			end
        end
    end
    
    for i = 1, #rm do
		self.m_animation[rm[i]] = nil
	end

	if update then
		self:updateVertex()
	end
end

return AnimBatch