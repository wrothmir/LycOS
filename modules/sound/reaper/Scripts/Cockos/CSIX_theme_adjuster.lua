-- Customized V6 Theme Adjuster for all CSIX Themes
-- Version: 3.5.0

-- note1: requires installation of image resources and fonts
-- note2: no 75/150pct scaling
-------------------------------------------------------
sTitle = 'CSIX | Theme Settings'
reaper.ClearConsole()

_desired_sizes = { { 590, 757}, { 850, 757 } }
OS = reaper.GetOS()
gfx.ext_retina = 1
drawScale,drawScale_nonmac,drawScale_inv_nonmac,drawScale_inv_mac = 1,1,1,1
resource_path = reaper.GetResourcePath()

_gfxw,_gfxh = table.unpack(_desired_sizes[reaper.GetExtState(sTitle,'showHelp') == 'false' and 1 or 2])

gfx.init(sTitle, _gfxw,_gfxh,
tonumber(reaper.GetExtState(sTitle,'dock')) or 0,
tonumber(reaper.GetExtState(sTitle,'wndx')) or 100,
tonumber(reaper.GetExtState(sTitle,'wndy')) or 50)

function debugTable(t)
  local str = ''
  reaper.ShowConsoleMsg('------ debug ------ \n')
  for i, v in pairs(t) do
    str = str..i..' = '..tostring(v)..'\n'
  end
  reaper.ShowConsoleMsg(str..'\n')
end

globalBorderX, globalBorderY = 6,4 -- docked border
activeTcpLayout, activeMcpLayout = 'A', 'A'

  --------- COLOURS ---------

palette = {}
palette.idx = {'LUNA','STRONG','MOCHA','TRENDY','BEACH','KITTY','FESTIVAL','GAMUT','FLOW1','FLOW2'}
palette.current = tonumber(reaper.GetExtState(sTitle,'paletteCurrent')) or 1
---
palette.LUNA = {{94,59,99},{53,93,93},{92,133,133},{103,152,204},{156,127,110},{153,154,102},{102,102,102},{102,101,153},{53,91,133},{64,60,156}}
palette.STRONG = {{240,71,43},{228,154,38},{241,196,15},{111,184,66},{68,156,199},{74,119,193},{129,71,212},{201,83,161},{176,177,161},{108,120,116}}
---
palette.MOCHA = {{154,100,100},{155,83,67},{197,192,170},{175,137,104},{231,162,112},{186,172,144},{134,165,144},{191,156,94},{107,120,106},{99,95,92}}
palette.TRENDY = {{128,137,137},{213,201,172},{246,142,81},{187,147,183},{189,217,75},{243,188,74},{150,206,183},{26,166,141},{124,180,210},{72,136,189}}
---
palette.BEACH = {{255,163,125},{237,143,218},{91,197,222},{127,252,195},{202,186,172},{200,209,192},{171,180,186},{135,182,179},{133,138,165},{234,217,123}}
palette.KITTY = {{236,186,81},{97,141,115},{228,145,195},{152,137,75},{137,230,252},{150,181,207},{66,111,246},{145,202,128},{218,59,128},{221,98,42}}
---
palette.FESTIVAL = {{115,66,50},{151,108,61},{126,86,108},{199,146,169},{93,146,123},{123,179,159},{128,212,228},{71,144,217},{95,108,172},{73,78,155}}
palette.GAMUT = {{238,238,238},{108,172,238},{235,235,16},{16,235,235},{16,235,16},{235,15,235},{235,16,16},{128,0,128},{104,104,104},{48,48,48}}
---
palette.FLOW1 = {{83,40,0},{105,53,0},{140,70,0},{165,84,0},{148,74,0},{121,61,0},{103,52,0},{81,39,0},{90,40,0},{74,31,0}}
palette.FLOW2 = {{0,80,80},{0,124,124},{0,167,167},{0,200,200},{0,179,178},{0,143,143},{0,122,122},{0,90,90},{0,118,118},{0,100,100}}
---

function getCurrentPalette()
  return palette.idx[palette.current] or 'LUNA'
end

function setCol(col)
  local r = col[1] / 255
  local g = col[2] / 255
  local b = col[3] / 255
  local a = 1
  if col[4] ~= nil then a = col[4] / 255 end
  gfx.set(r,g,b,a)
end

function setCustCol(track, r,g,b)
  reaper.SetTrackColor(reaper.GetTrack(0, track),reaper.ColorToNative(r,g,b))
end


--------------- master color (cache) ----------------

local masterColor = { r = 0, g = 0, b = 0 }

function refreshMasterColor()
  --reaper.ShowConsoleMsg('Refreshing masterColor cache...\n')
  if not paramsIdx or not paramsIdx.A then return end
  local idx = paramsIdx.A
  for _, k in ipairs({ "r", "g", "b" }) do
    local param = idx["masterColor_" .. k] or -1
    masterColor[k] = select(3, reaper.ThemeLayout_GetParameter(param)) or 0
  end
  --reaper.ShowConsoleMsg(string.format("Cached Master Color — R: %d, G: %d, B: %d\n", masterColor.r, masterColor.g, masterColor.b))
end

function getMasterCol()
  return masterColor.r, masterColor.g, masterColor.b
end

---------------- master color (set) -----------------

function MasterCustomColor()
  local master = reaper.GetMasterTrack(0)
  local wasSelected = reaper.IsTrackSelected(master)

  local prevSel = {} --store track selection
  for i = 0, reaper.CountTracks(0) - 1 do
    local tr = reaper.GetTrack(0, i)
    if reaper.IsTrackSelected(tr) then
      prevSel[#prevSel + 1] = tr
    end
  end

  if not wasSelected then
    reaper.SetOnlyTrackSelected(master)
  end

  local r, g, b
  if gfx.mouse_cap & 16 == 16 then  --Alt held resets
    r, g, b = 0, 0, 0
  else
    local ok, col = reaper.GR_SelectColor()
    if ok == 0 then goto restore end  --Cancelled
    r, g, b = reaper.ColorFromNative(col)
  end

  for _, k in ipairs({ "r", "g", "b" }) do
    local val = ({ r = r, g = g, b = b })[k]
    local idx = paramsIdx.A["masterColor_" .. k]
    if idx then
      reaper.ThemeLayout_SetParameter(idx, val, true)
      masterColor[k] = val  --update rgb cache
    end
  end
  -- reaper.ShowConsoleMsg(string.format("Master Color Updated — R: %d, G: %d, B: %d\n", masterColor.r, masterColor.g, masterColor.b))

  ::restore::  --restore track selection
  reaper.Main_OnCommand(40297, 0)  --unselect all
  for _, tr in ipairs(prevSel) do
    reaper.SetTrackSelected(tr, true)
  end
  reaper.SetTrackSelected(master, wasSelected)
  redraw = 1
end

-------------- master color (picker) ----------------

local function drawMasterColorSwatch(self)
  local drawscale = gfx.ext_retina or 1
  local radius = 6 * drawscale
  local cx = drawscale * ((self.drawx or self.x or 0) + (self.drawW or self.w or 0) / 2)
  local cy = drawscale * ((self.drawy or self.y or 0) + (self.drawH or self.h or 0) / 2)
  local r, g, b = getMasterCol()
  if r == 0 and g == 0 and b == 0 then return end

  gfx.set(r / 255, g / 255, b / 255, 1)
  gfx.circle(cx, cy, radius, true)  --fill
  gfx.set(0, 0, 0, 0.3)
  gfx.circle(cx, cy, radius, false)
end

------------------------------------------------------------

function applyCustCol(col)
  if type(col) ~= 'table' or #col < 3 then return end
  reaper.Undo_BeginBlock()

  local mouseCap = gfx.mouse_cap

  if mouseCap & 8 == 8 then    -- Shift held = update master color
    local r, g, b = table.unpack(col)

    if mouseCap & 16 == 16 then  -- Shift + Alt held = reset master color
      r, g, b = 0, 0, 0
    end

    for k, v in pairs({r=r, g=g, b=b}) do
      local idx = paramsIdx.A["masterColor_" .. k]
      if idx then
        reaper.ThemeLayout_SetParameter(idx, v, true)
        masterColor[k] = v
      end
    end
  end

  local count = reaper.CountSelectedMediaItems(0)

if count == 0 or (cursorContext2 == 0) or (count > 0 and mouseCap & 4 ~= 4) then  --No modifier = set track colors
  for i = 0, reaper.CountTracks(0)-1 do
    local track = reaper.GetTrack(0, i)
    if reaper.IsTrackSelected(track) then
      local isMaster = reaper.GetMasterTrack(0) == track
      if (mouseCap & 8 == 0) or isMaster then
        setCustCol(i, table.unpack(col))
      end
    end
  end

  elseif cursorContext2 ~= 0 then  --Ctrl held = set item colors
    for selindex = 0, count-1 do
      local sel_item = reaper.GetSelectedMediaItem(0, selindex)
      reaper.SetMediaItemInfo_Value(sel_item, 'I_CUSTOMCOLOR', reaper.ColorToNative(table.unpack(col)) | 0x1000000)
      reaper.UpdateItemInProject(sel_item)
    end
  end

  reaper.Undo_EndBlock('custom color changes', -1)
  reaper.ThemeLayout_RefreshAll()
end

function paletteChoose(p)
  local _v = palette.current + p[2]
  if _v < 1 then _v = 1
  elseif _v > #palette.idx then _v = #palette.idx end
  palette.current = _v
end

function getCustCol(track)
  local c = reaper.GetTrackColor(reaper.GetTrack(0, track))
  if c == 0 then return nil end
  return reaper.ColorFromNative(c)
end

function addRandPalette(pal, curpal)
  local pass = math.floor(#pal/#curpal)
  local offs, adj, wadj = #pal, math.floor((pass+2)/3), 1 + (pass%3)
  for i = 1, #curpal do
    local a = { table.unpack(curpal[i]) }
    if a[wadj] > 128 then a[wadj] = math.max(a[wadj] - adj,0) else a[wadj] = math.min(a[wadj] + adj,255) end
    pal[#pal+1] = a
  end
  for i = #curpal, 2, -1 do
    local j = math.random(i)+offs
    pal[offs+i], pal[j] = pal[j], pal[offs+i]
  end
end

------------------------------------------------------------

function applyPalette()
if reaper.MB(translate('Assigns random colors to ALL tracks in the Project\nusing the selected Palette.\r\n\r\n'
.. 'Tracks which share a color will be given the\nsame new color.\n'), translate('Recolor entire Project?'), 1) == 1 then

  local curpal = palette[getCurrentPalette()] or palette.LUNA
  local randpal = {}

  reaper.Undo_BeginBlock()
  local cnt, colmap = 1, {}
  for i = 0, reaper.CountTracks(0)-1 do
    local r, g, b = getCustCol(i)
    if b ~= nil then
      local colkey = (r<<16)|(g<<8)|b
      if colmap[colkey] == nil then
        if cnt > #randpal then
          addRandPalette(randpal,curpal)
        end
        colmap[colkey] = cnt
        cnt = cnt + 1
      end
      local wc=colmap[colkey]
      setCustCol(i, table.unpack(randpal[wc]))
    end
  end
  reaper.Undo_EndBlock('Recolor using palette',-1)
    reaper.ThemeLayout_RefreshAll()
end
    end

------------------------------------------------------------

function applyChildren()
  local r = reaper
  if not r.APIExists('CF_GetSWSVersion') then
    r.ShowMessageBox(translate('This function requires the SWS/S&M extension.\n\nSWS can be downloaded from:\nwww.sws-extension.org.'), translate('Error'), 0)
    return
  end

  local selchildren = r.NamedCommandLookup('_SWS_SELCHILDREN')
  local colchildren = r.NamedCommandLookup('_SWS_COLCHILDREN')
  local itemtotrkcolor = r.NamedCommandLookup('_SWS_ITEMTRKCOL')
  local coloritem = true
  local gradientstep = -15
  local trktbl = {}

  local function getseltracktable()
    for i = 0, r.CountSelectedTracks(0) - 1 do
      trktbl[#trktbl + 1] = r.GetSelectedTrack(0, i)
    end
  end

  local function seltracktable()
    for _, t in ipairs(trktbl) do r.SetTrackSelected(t, true) end
  end

  local function main()
    if gfx.mouse_cap == 4 then gradientstep = -10       -- Ctrl
    elseif gfx.mouse_cap == 8 then gradientstep = 20     -- Shift
    elseif gfx.mouse_cap == (4 + 8) then gradientstep = 10    -- Ctrl + Shift
    elseif gfx.mouse_cap == 16 then gradientstep = 0     -- Alt
    end

    local track = r.GetSelectedTrack(0, 0)
    if not track then return end
    local ColorNative = r.GetTrackColor(track)
    if ColorNative == 0 then return end

    r.Main_OnCommandEx(colchildren, 0, 0)
    r.Main_OnCommandEx(selchildren, 0, 0)

    local childCount = r.CountSelectedTracks(0)
    local step = math.ceil((gradientstep * 10) / (childCount + 1))

    local rC, gC, bC = r.ColorFromNative(ColorNative)
    for i = 0, childCount - 1 do
      local child = r.GetSelectedTrack(0, i)
      if child then
        rC = math.min(math.max(rC + step, 0), 255)
        gC = math.min(math.max(gC + step, 0), 255)
        bC = math.min(math.max(bC + step, 0), 255)
        r.SetTrackColor(child, r.ColorToNative(rC, gC, bC))
        if coloritem then r.Main_OnCommandEx(itemtotrkcolor, 0, 0) end
      end
    end
  end

  r.Undo_BeginBlock()
  r.PreventUIRefresh(1)

  getseltracktable()
  if #trktbl > 0 then
    for _, t in ipairs(trktbl) do
      r.Main_OnCommandEx(40289, 0, 0)
      r.Main_OnCommandEx(40769, 0, 0)
      r.SetTrackSelected(t, true)
      main()
    end
    r.Main_OnCommandEx(40769, 0, 0)
    seltracktable()
  end

  r.PreventUIRefresh(-1)
  r.Undo_EndBlock('gradient to children', 0)
end


--------------------- native actions -----------------------

function setTrackDefaultColor()
  reaper.Main_OnCommand(reaper.NamedCommandLookup('40359'), -1)
end

function setItemsDefaultColor()
  reaper.Main_OnCommand(reaper.NamedCommandLookup('40707'), -1)
end

function setTakesDefaultColor()
  reaper.Main_OnCommand(reaper.NamedCommandLookup('41337'), -1)
end

function TrackRandomColor()
  reaper.Main_OnCommand(reaper.NamedCommandLookup('40358'), -1)
end

function TrackCustomColor()
  reaper.Main_OnCommand(reaper.NamedCommandLookup('40357'), -1)
end

function resetRandomGenerator()
  reaper.Main_OnCommand(reaper.NamedCommandLookup('41343'), -1)
end

function ToggleExtTimecodeSync()
  reaper.Main_OnCommand(reaper.NamedCommandLookup('40620'), -1)
end


  ---------- TEXT -----------

textPadding = 3

local ostype = reaper.GetOS()
local isMac = ostype == "OSX64" or ostype == "OSX32"
local isWindows = ostype:match("^Win")
local isLinux = not isMac and not isWindows

local font = isLinux and "Roboto" or "Roboto"

if isMac or isLinux then
  gfx.setfont(1, font, 11)
  gfx.setfont(2, font, 11)
  gfx.setfont(3, font, 12)
  gfx.setfont(4, font, 16) -- used in: undocked palette title
  gfx.setfont(5, font, 11) -- IMPORTANT: match TCP & EnvCP labels
  gfx.setfont(11, font, 22)
  gfx.setfont(12, font, 22)
  gfx.setfont(13, font, 24)
  gfx.setfont(14, font, 31) -- used in : undocked palette title
  gfx.setfont(15, font, 25)
else -- Windows
  gfx.setfont(1, font, 13)
  gfx.setfont(2, font, 13)
  gfx.setfont(3, font, 14)
  gfx.setfont(4, font, 15) -- used in : undocked palette title
  gfx.setfont(5, font, 13) -- IMPORTANT: match TCP & EnvCP labels
  gfx.setfont(11, font, 26)
  gfx.setfont(12, font, 26)
  gfx.setfont(13, font, 30)
  gfx.setfont(14, font, 36) -- used in : undocked palette title
  gfx.setfont(15, font, 30)
end

if reaper.LocalizeString then
  translate = function(s) return reaper.LocalizeString(s or 'N/A', 'CSIX_theme_adjuster') end
else
  translate = function(s) return s or '---' end
end


function text(str,x,y,w,h,align,col,style,lineSpacing,vCenter,wrap)
  local lineSpace = drawScale*(lineSpacing or 11)
  setCol(col or {255,255,255})
  gfx.setfont(style or 1)

  local lines = nil
  str = translate(str)
  if wrap == true then
    lines = textWrap(str,drawScale * 105)
  else
    lines = {}
    for s in string.gmatch(str, "([^#]+)") do
      table.insert(lines, s)
    end
  end
  if vCenter ~= false and #lines > 1 then
    y = y - lineSpace/2
  end
  for k,v in ipairs(lines) do
    gfx.x, gfx.y = x,y
    gfx.drawstr(v,align or 0,x+(w or 0),y+(h or 0))
    y = y + lineSpace
  end
end

function textWrap(str,w) -- returns array of lines
  local lines,curlen,curline,last_sspace = {}, 0, '', false
  -- enumerate words
  for s in str:gmatch("([^%s-/]*[-/]* ?)") do
    local sspace = false -- set if space was the delimiter
    if s:match(' $') then
      sspace = true
      s = s:sub(1,-2)
    end
    local measure_s = s
    if curlen ~= 0 and last_sspace == true then
      measure_s = " " .. measure_s
    end
    last_sspace = sspace

    local length = gfx.measurestr(measure_s)
    if length > w then
      if curline ~= "" then
        table.insert(lines,curline)
        curline = ""
      end
      curlen = 0
      while length > w do
        -- split up a long word, decimating measure_s as we go
        local wlen = string.len(measure_s) - 1
        while wlen > 0 do
          local sstr = string.format("%s%s",measure_s:sub(1,wlen), wlen>1 and "-" or "")
          local slen = gfx.measurestr(sstr)
          if slen <= w or wlen == 1 then
            table.insert(lines,sstr)
            measure_s = measure_s:sub(wlen+1)
            length = gfx.measurestr(measure_s)
            break
          end
          wlen = wlen - 1
        end
      end
    end
    if measure_s ~= "" then
      if curlen == 0 or curlen + length <= w then
        curline = curline .. measure_s
        curlen = curlen + length
      else
        -- word would not fit, add without leading space and remeasure
        table.insert(lines,curline)
        curline = s
        curlen = gfx.measurestr(s)
      end
    end
  end
  if curline ~= "" then
    table.insert(lines,curline)
  end
  return lines
end

  --------- IMAGES ----------

function loadImage(idx, name)
  local str = debug.getinfo(1, 'S').source:match[[^@(.*[\/])[^\/]-$]]..'CSIX_theme_adjuster_images/'
  if gfx.loadimg(idx, str..name) == -1 then reaper.ShowConsoleMsg('image '..name..' not found') end
end

image_idx,image_idx_size = {},0
function getImage(img,drawScale)
  if drawScale ~= 2 then drawScale = 1 end

  local cache_rec = image_idx[img]
  if cache_rec ~= nil then
    if cache_rec.scale == drawScale then return cache_rec.idx end
  else
    cache_rec = { idx=image_idx_size }
    image_idx[img] = cache_rec
    image_idx_size = image_idx_size + 1
  end
  if drawScale == 2 then img = img .. '@2x' end
  loadImage(cache_rec.idx,img .. '.png')
  cache_rec.scale = drawScale
  return cache_rec.idx
end


  --------- OBJECTS ---------

function adoptChild(parent,o)
  if parent ~= nil then
    if parent.children == nil then parent.children = { o }
    else parent.children[#parent.children+1] = o end

    if parent.has_children_outside ~= 1 then
      if o.has_children_outside == 1 then
        parent.has_children_outside = 1
      else
        if o.x ~= nil and o.y ~= nil and parent.w ~= nil and parent.h ~= nil then
          if o.x < 0 or o.y < 0 or o.x+(o.w or 1) > parent.w or o.y+(o.h or 1) > parent.h then
            parent.has_children_outside = 1
          end
        end
      end
    end
  end
end

Element = {}
function Element:new(parent,o)
local o = o or {}
  self.__index = self
  self.x, self.y = self.x or 0, self.y or 0
  adoptChild(parent,o)
  setmetatable(o, self)
  return o
end

Button = Element:new()
function Button:new(parent,o)
  self.__index = self
  o.x, o.y, self.w, self.h, self.border = o.x or 0, o.y or 0, o.w or 30,o.h or 30, o.border or ''
  adoptChild(parent,o)
  setmetatable(o, self)
  return o
end

ButtonLabel = Element:new()
function ButtonLabel:new(parent,o)
  self.__index = self
  self.flow = true
  o.text={str=o.text.str, col={180,180,181}, align=4, style=1}
  self.x, self.h, self.w, self.border = 2, 30, o.w or 73, o.border or ''
  adoptChild(parent,o)
  setmetatable(o, self)
  return o
end

Readout = Element:new()

Spinner = Element:new()
function Spinner:new(parent,o)
  self.__index = self
  self.x, self.y, self.w, self.h = 0,0,o.w or 119,o.h or 30
  self.flow = o.flow
  self.border = o.border or ''
  local spinStyle = o.spinStyle or 'light'
  local i = getImage(spinStyles[spinStyle].buttonLimage,1)
  self.buttonW = gfx.getimgdim(i) /3
  if spinStyles[spinStyle].title ~= false then
    local topBar = Element:new(o,{x=self.buttonW/2,y=2,w=self.w-self.buttonW,h=spinStyles[spinStyle].title.h,color=spinStyles[spinStyle].label.col,interactive=false})
  end
  if spinStyles[spinStyle].readout ~= false then
    local bottomBar = Element:new(o,{x=self.buttonW/2,y=spinStyles[spinStyle].readout.y,w=self.w-self.buttonW,h=spinStyles[spinStyle].readout.h,color=spinStyles[spinStyle].readout.col,interactive=false})
  end
  if o.spinStyle == 'image' then
    local ir = Readout:new(o,{x=self.buttonW,y=spinStyles[spinStyle].readout.y,w=self.w-(2*self.buttonW),h=spinStyles[spinStyle].readout.h,border='',
                      valsImage = o.valsImage, action = o.action, param={0}})
  else
    if spinStyles[spinStyle].readout ~= false then
      local r = Readout:new(o,{x=self.buttonW,y=spinStyles[spinStyle].readout.y,w=self.w-(2*self.buttonW),h=spinStyles[spinStyle].readout.h,border='',
                  text={str='---',align=5,val=o.value, col=spinStyles[spinStyle].readout.strCol, style=2},
                  action = o.action, param={o.param}, valsTable=o.valsTable})
            
            r.onDoubleClick = function(self) -- reset to def val
            if not self.param or not self.param[1] then return end
            local p = paramIdxGet(self.param[1])
            if not p then return end

            local retval, _, value, def = reaper.ThemeLayout_GetParameter(p)
            if retval and value ~= nil and def ~= nil and value ~= def then
            reaper.ThemeLayout_SetParameter(p, def, true)
            paramGet = 1
            redraw = 1
            end
        end
    end
  end
  local hitBox = Element:new(o,{x=0,y=0,w=self.w,h=self.h,action = o.action, param={o.param},helpR=o.helpR,helpL=o.helpL})
  local l = Button:new(hitBox,{x=0,y=2,w=self.buttonW,h=self.h,img=spinStyles[spinStyle].buttonLimage,imgType=3,action=o.action,param={o.param,-1},helpR=o.helpR,helpL=o.helpL})
  local r = Button:new(hitBox,{x=self.w-self.buttonW,y=2,w=self.buttonW,h=self.h,img=spinStyles[spinStyle].buttonRimage,imgType=3,action=o.action,param={o.param,1},helpR=o.helpR,helpL=o.helpL})
  if o.title~=nil and spinStyles[spinStyle].title ~= false then
    Element:new(o,{x=self.buttonW,y=2,w=self.w-(2*self.buttonW),h=spinStyles[spinStyle].title.h,action=o.action,param={o.param}, -- label
                  text={str=(o.title or'LABEL STR'), align = 5, col=spinStyles[spinStyle].label.strCol}})
  end
  o.valsImage = nil -- was only there temporarily, to be passed to the readout child
  adoptChild(parent,o)
  setmetatable(o, self)
  return o
end

spinStyles = {
  light = {buttonLimage = 'button_left', buttonRimage = 'button_right',
          title = {h=13},
          label = {strCol={180,180,181}, col={33,34,35}},
          readout = {y=14,h=17,col=nil}
  },
  image = {buttonLimage = 'left', buttonRimage = 'right', title = false,
          readout = {y=3,h=10,col=nil}
  }
}

Fader = Element:new()
function Fader:new(parent,o)
  o.parent = parent;
  self.__index = self
  o.x, o.y, self.w, self.h = o.x or 0, o.y or 0, o.w or 21,o.h or 27
  self.img, self.imgType ='slider', 3
  self.range, self.action, self.param, self.helpR = o.range, o.action, o.param, o.helpR
  adoptChild(parent,o)
  setmetatable(o, self)
  return o
end

FaderBg = Element:new()
function FaderBg:new(parent,o)
  self.__index = self
  o.x, o.y, self.w, self.h = o.x or 0, o.y or 0, o.w or 21,o.h or 27
  o.parent = parent
  self.action, self.param, self.helpR = o.action, o.param, o.helpR
  adoptChild(parent,o)
  setmetatable(o, self)
  return o
end

ParamTable = Element:new()
function ParamTable:new(parent,o)
  self.__index = self
  self.h = o.h
  for i, v in ipairs(o.valsTable.columns) do
    if v.text.col ~= nil then thisCol = {180,180,181} else thisCol = {180,180,181} end
    Element:new(o, {x=44+i*82,y=0,w=80,h=22,text={str=v.text.str,style=1,align=9,col=thisCol}}) --column titles
  end
  for i=1, #o.valsTable.rows do ParamRow:new(o,o.valsTable,i) end
  Element:new(o, {x=124,y=0,w=1,h=o.h,color={254,254,254,30}}) --
  Element:new(o, {x=206,y=0,w=1,h=o.h,color={254,254,254,30}}) -- column
  Element:new(o, {x=288,y=0,w=1,h=o.h,color={254,254,254,30}}) -- dividers
  Element:new(o, {x=370,y=0,w=1,h=o.h,color={254,254,254,30}}) --
  adoptChild(parent,o)
  setmetatable(o, self)
  return o
end

ParamRow = Element:new()
function ParamRow:new(parent,valsTable,rowIdx)
  local o = {}
  self.__index = self
  if (rowIdx%2==0) then rowBgCol = {46,48,51} else rowBgCol = {0,0,0,35} end --- bg scheme color (theme -- fill rows global)
  local row = Element:new(parent, {x=0,y=rowIdx*25+5,w=453,h=25,color=rowBgCol})
  local titleW = 114
  if valsTable.rows[rowIdx].img ~= nil then
    Element:new(row, {x=91,y=0,w=23,h=25,img=valsTable.rows[rowIdx].img}) --row title images
    titleW = 80
  end
  Element:new(row, {x=0,y=0,w=titleW,h=25,text={str=valsTable.rows[rowIdx].text.str,style=1,align=6,col={180,180,181}}})  --row titles
  for i, v in ipairs(valsTable.columns) do
    Button:new(row, {x=44+i*82,y=0,w=81,h=25,img=valsTable.img,imgType=3,action=doFlagParam,param={valsTable.rows[rowIdx].param,v.visFlag}})
  end
  adoptChild(parent,o)
  setmetatable(o, self)
  return o
end

Palette = Element:new()
function Palette:new(parent,o)
  o.w = o.cellW * 10
  self.__index = self
  for i=1,10 do
    local p = Button:new(o,{flow=true,x=0,y=0,w=o.cellW, h=o.h, img=o.img or 'color_apply',imgType=3, action=o.action}) -- used to be x=2 to make the dividers
  end
  adoptChild(parent,o)
  setmetatable(o, self)
  return o
end

Swatch = Element:new()
function Swatch:new(parent,o)
  self.__index = self
  self.x, self.y, self.w, self.h = o.x or 0,o.y or 0,200,30
  local SwatchHitbox = SwatchHitbox:new(o, {paletteIdx = o.paletteIdx})
  for i,v in pairs(palette[palette.idx[o.paletteIdx] or 'LUNA']) do
    local p = Element:new(o,{x=((i-1)*20),y=0,w=20, h=15,color=v})
  end
  local div = Element:new(o, {x=0,y=30,w=200,h=1})
  gfx.setfont(2)
  local palStr,tmp = undockPaletteNamesVals[o.paletteIdx]
  local palStrW = gfx.measurestr(palStr)+12
  local label = Element:new(o, {x=100-(palStrW/2),y=20,w=palStrW+10,h=18,text={str=palStr,style=2,align=9},color={39,41,43}})
  adoptChild(parent,o)
  setmetatable(o, self)
  return o
end

SwatchHitbox = Element:new()
function SwatchHitbox:new(parent,o)
  o.parent = parent;
  self.__index = self
  self.x, self.y, self.w, self.h = 0,0,200,34
  self.helpR=helpR_choosePalette
  adoptChild(parent,o)
  setmetatable(o, self)
  return o
end

function Swatch:doParamGet()
  if self.paletteIdx == palette.current then
    self.children[12].color = {254,254,254,140}
    self.children[13].text.col = {115,235,255,255}
  else
    self.children[12].color = {254,254,254,60}
    self.children[13].text.col = {254,254,254,140}
  end
end

function Fader:doParamGet()
  local lx = self.x;
  local tmp,title,value,defValue,min,max = reaper.ThemeLayout_GetParameter(self.param)
  if max > min then
    self.x = 352 * ((value - min) / (max - min))
  else
    self.x = 352/2
  end
  if lx ~= self.x then
    self.parent:onSize()
    redraw = 1
  end
end

-------------- PARAMS --------------

function indexParams()
  paramsIdx ={['A']={},['B']={},['C']={},['global']={}}
  local i = 1
  while reaper.ThemeLayout_GetParameter(i) ~= nil do
    local tmp, desc = reaper.ThemeLayout_GetParameter(i)
    local layout, paramDesc = desc:match("^([ABC])_(.+)")
    if layout and paramsIdx[layout] then
      paramsIdx[layout][paramDesc] = i
    elseif desc == 'Gamma' or desc == 'Shadows' or desc == 'Midtones' or -- read color adjust
            desc == 'Highlights' or desc == 'Saturation' or desc == 'Tint' then
      paramsIdx.global[desc] = i
    end
    i = i + 1
  end
  redraw = 1
end

function paramIdxGet(param)
  if paramsIdx == nil then reaper.ShowConsoleMsg("paramsIdx is nil\n") end
  local panel = param and string.sub(param,0,(string.find(param, "%_")-1))
  if param == 'tcp_indent' or param == 'ctrl_Param_301' or param == 'tcp_control_align' or param == 'tcp_customButton' or param == 'tcp_meterFlip' 
        or param == 'tcp_indentGuide' or param == 'tcp_fxParmVis' or param == 'tcp_LabelMeasure' or param == 'tcp_LabelSize' or param == 'ctrl_Param_201'
        or param == 'mcp_indent' or param == 'mcp_control_align' or param == 'mcp_customButton' or param == 'glb_wideMaster' or param == 'glb_simpleMaster' 
        or param == 'mcp_fxEmbedSizeMain' or param == 'glb_TitleTrackSize' or param == 'glb_TitleTrackCol'
        or panel == 'envcp' or panel == 'trans' or panel == 'glb' then --params which act on ALL layouts
    local p = paramsIdx['A'][param]
    if p ~= nil then return p end
  else
    if panel ~= nil and param ~= nil then
      local p = paramsIdx[activeLayout[panel]][param]
      if p ~= nil then return p end
    end
  end
end

function paramToVal(param, v)
  if type(v) ~= "number" then return nil, '' end
  local val, suffix = v, ''
  if param == -1000 then val = v / 1000
  elseif param == -1001 or param == -1002 or param == -1003 then val = v / 256
  elseif param == -1004 then val = math.floor(v / 2.56 + 0.5); suffix = ' %'
  elseif param == -1005 then val = math.floor(v * 0.9375 - 180 + 0.5); suffix = ' °'
  end
  return val, suffix
end

function valToParam(param, v)
  if type(v) ~= "number" then return nil end
  if param == -1000 then return v * 1000
  elseif param == -1001 or param == -1002 or param == -1003 then return v * 256
  elseif param == -1004 then return math.floor(v * 2.56 + 0.5)
  elseif param == -1005 then return math.floor((v + 180) / 0.9375 + 0.5)
  elseif param >= 0 then return v
  end
  return nil
end

function colorAdjustFromTheme()  --read color adjust
  if not paramsIdx or not paramsIdx.global then return end

  local function getValByDesc(desc)
    local idx = paramsIdx.global[desc]
    if not idx then return nil end
    local ok, paramDesc, val = reaper.ThemeLayout_GetParameter(idx)
    if not ok or paramDesc ~= desc then return nil end
    return val
  end

  local adjustments = {
    { param = 'Gamma',      idx = -1000 },
    { param = 'Shadows',    idx = -1001 },
    { param = 'Midtones',   idx = -1002 },
    { param = 'Highlights', idx = -1003 },
    { param = 'Saturation', idx = -1004 },
    { param = 'Tint',       idx = -1005 },
  }

  for _, adj in ipairs(adjustments) do
    local val = getValByDesc(adj.param)
    if val then
      reaper.ThemeLayout_SetParameter(adj.idx, val, true)
    end
  end
end

function Element:doParamGet()
  if self.visible ~= false then paramGetChildren(self.children) end
end

function paramGetChildren(ch)
  if ch ~= ni then
    for i, v in ipairs(ch) do
      v:doParamGet() --get all the param values for your children.
    end
  end
end

function Button:doParamGet()
  if self.action == paramToggle then  -- then you're a toggle state
    if type(self.param) ~= 'number' then
      self.param = paramIdxGet(self.param)
    end
    local tmp,tmp,v = reaper.ThemeLayout_GetParameter(self.param or -1)
    if v == 1 then
      self.drawImg = tostring(self.img..'_on')
    else self.drawImg = nil
    end
  end
  if self.action == doFlagParam  then  --param table cells
    local p = paramIdxGet(self.param[1])
    local name,desc,value = reaper.ThemeLayout_GetParameter(p)
    if value & self.param[2] ~= 0 then
      if self.param[2] == 8 and self.img == 'cell_hide' then  -- use red hide images on column 4 of the tcp's table
       self.drawImg = tostring(self.img..'_all')
      else
        self.drawImg = tostring(self.img..'_on')
      end
    else self.drawImg = nil
    end
  end
end

function Readout:doParamGet()
  if self.param ~= nil and self.param[1]~= nil then
    if self.valsTable ~= nil then
      if self.action == nil then -- then you're just a palette
        self.text.str = self.valsTable[palette.current]
      else -- if you're not a palette you must be a paramSet spinner
        local p = paramIdxGet(self.param[1])
        local tmp,tmp,value,def = reaper.ThemeLayout_GetParameter(p or 0)
        if value <= #self.valsTable then
          self.text.str = self.valsTable[value]
        else self.text.str = "ERR "..p.." "..value
        end
        self.text.col = (value == def) and {180,180,181} or {172,212,255} --blue if not default
      end
    elseif self.action == doPageSpin then self.imgValueFrame = getEditPageIndex()-1
    elseif self.action == doFader then
      local tmp,tmp,value = reaper.ThemeLayout_GetParameter(self.param[1]) --< color faders have param as number, no need to lookup 
      local v, suffix = paramToVal(self.param[1],value)
      self.text.str = string.format(suffix == "" and "%.2f" or "%d%s",v,suffix);
    elseif self.action == doGenericFader then
      local tmp,desc,value = reaper.ThemeLayout_GetParameter(self.param[1])
      if tmp ~= nil then
        if self.userEntry ~= nil then
          self.text.str = value
        else
          self.text.str = desc
        end
      end
    end
  end
end

function paramSet(param)
  local p,v = param[1], param[2]
  --reaper.ShowConsoleMsg('paramSet '..p..' to '..v..'\n')
  if type(p) ~= 'number' then p = paramIdxGet(p) or 0 end
  local name,desc,value,defvalue,minvalue,maxvalue = reaper.ThemeLayout_GetParameter(p)
  newValue = value + v
  if newValue < minvalue then newValue = minvalue end
  if newValue > maxvalue then newValue = maxvalue end
  reaper.ThemeLayout_SetParameter(p, newValue, true)
  reaper.ThemeLayout_RefreshAll()
  paramGet = 1
end

function doFlagParam(param) --param name, visFlag
  local p = paramIdxGet(param[1])
  local name,desc,value = reaper.ThemeLayout_GetParameter(p)
  reaper.ThemeLayout_SetParameter(p, value ~ param[2], true)
  reaper.ThemeLayout_RefreshAll()
  paramGet = 1
end

function doGenericParams()
  for i=2,#_themeParameterPage_und.children do
    if reaper.ThemeLayout_GetParameter(i-1) ~= nil then _themeParameterPage_und.children[i].visible = true
    else _themeParameterPage_und.children[i].visible = false
    end
  end
end

function paramToggle(p)
  if p ~= nil then
    local tmp,tmp,v = reaper.ThemeLayout_GetParameter(p)
    if v == 1 then
      reaper.ThemeLayout_SetParameter(p, 0, true)
    else
      reaper.ThemeLayout_SetParameter(p, 1, true)
    end
    reaper.ThemeLayout_RefreshAll()
  end
end

function actionToggle(p)
  reaper.Main_OnCommand(p, 0)
  needReaperStateUpdate=1
end

------------ doUpdateState gets/refreshes values. it should set redraw if a value changed. 
------------ needReaperStateUpdate is 1 if the project has changed (implies redraw)

function Element:doUpdateState()
  if self.updateState ~= nil then
    self:updateState()
  end

  if self.children ~= nil then
    for i, v in ipairs(self.children) do
      if v.visible ~= false then v:doUpdateState() end
    end
  end
end

function Button:doUpdateState()
  if self.updateState ~= nil then   --<< swap over to this for image buttons
    self:updateState()
  end

  local old = self.drawImg
  if self.action == actionToggle then
    local v = reaper.GetToggleCommandState(self.param)
    if v == 1 then
      self.drawImg = tostring(self.img..'_on')
    else self.drawImg = nil
    end
  end
  if self.action == doActiveLayout then
    local p, a = 'P_TCP_LAYOUT', ''
    if self.param[1] == 'mcp' then p = 'P_MCP_LAYOUT' end
    if self.param[2] == activeLayout[self.param[1]] then a = '_on' end  --you are the button for the active layout

    self.drawImg = nil
    if a ~= nil then self.drawImg = self.img..a end
  end
  if self.children ~= nil then
    for i, v in ipairs(self.children) do
      if v.visible ~= false then v:doUpdateState() end
    end
  end
  if old ~= self.drawImg then redraw = 1 end
end

function Fader:doUpdateState()
  if self.updateState ~= nil then
    self:updateState()
  end
  local tmp,title,value,defValue,min,max = reaper.ThemeLayout_GetParameter(self.param)
  local lx = self.x;
  if self.dragStart ~= nil then
    local dX = gfx.mouse_x - self.dragStart
    local v = math.floor(dX * ((max - min)/(352 * drawScale)))
    newValue = self.dragStartValue + v
    if newValue < min then newValue = min end
    if newValue > max then newValue = max end
    if max > min then
      self.x = 352 * ((newValue - min) / (max - min))
    else
      self.x = 352/2
    end
  else
    self:doParamGet()
  end
end

function Readout:doUpdateState()
  if self.updateState ~= nil then
    self:updateState()
  end
  self:doParamGet()
end


function noneSelected(self)
  if needReaperStateUpdate == 1 then
    local trackCount = reaper.CountTracks(0)-1
    local noneSelected = true
    for i=0, trackCount do
      if reaper.IsTrackSelected(reaper.GetTrack(0, i)) == true then
        noneSelected = false
        break
      end
    end
    if self.imgFalse ~= nil then
      if noneSelected == true then self.img = self.imgTrue else self.img = self.imgFalse end
    end
  end
end


function read_ini(file, sec, ent)
  local insec, str, section = false, string.lower(ent), string.lower(sec)
  for l in io.lines(file) do
    local m = string.match(l,"^%s*[[](.-)[]]")
    if m ~= nil then
      insec = section == string.lower(m)
    else
      if insec then
        local a = string.match(l,"^%s*(.-)=")
        if a ~= nil and str == string.lower(a) then
          return string.match(l,"^.-=(.*)")
        end
      end
    end
  end
end

reaperDpi = {'tcp','mcp','envcp','trans'}
dpiParams = {{'apply_50','50%_'},{'apply_75','75%_'},{'apply_100',''},{'apply_150','150%_'},{'apply_200','~2x_'}}
function getReaperDpi()

  for i, v in ipairs(reaperDpi) do
    local ok, dpi_str = reaper.ThemeLayout_GetLayout(v,-3)
    if reaperDpi[v] == nil then reaperDpi[v] = {} end
    local dpi = tonumber(dpi_str)
    if ok == true and dpi ~= nil and dpi > 0 then
      reaperDpi[v].new = dpi / 256
    else
      reaperDpi[v].new = 1.0
    end

    local p = {3,4,5}
    if reaperDpi[v].old == nil or reaperDpi[v].old ~= reaperDpi[v].new then
      if reaperDpi[v].new > 1.34 then
        p = {2,3,4}
        if reaperDpi[v].new > 1.74 then p = {1,2,3} end
      end
      for i=1,3 do
        if apply[v][i]==nil then apply[v][i] = {} end
        apply[v][i].img, apply[v][i].param = dpiParams[p[i]][1], {v,dpiParams[p[i]][2]}
        apply.und[v][i].img, apply.und[v][i].param = apply[v][i].img, apply[v][i].param
      end
      reaperDpi[v].old = reaperDpi[v].new
      redraw = 1
    end
  end
end

function measureTrackNames(trackCount)
  local nameChanged = 0
  for i=0, trackCount do
    local tmp, trackName = reaper.GetSetMediaTrackInfo_String(reaper.GetTrack(0, i), 'P_NAME', '', false)
    if (trackNames[i] ~= trackName) then -- track name has changed
      trackNames[i] = trackName
      gfx.setfont(5) -- ORG name-size auto
      trackNamesW[i] = gfx.measurestr(trackName)
      nameChanged = 1
      redraw = 1
    end
  end
  if nameChanged == 1 then
    local trackNamesWMax = 25 -- setting a minimum size
    for k,v in pairs(trackNamesW) do
      if v > trackNamesWMax then trackNamesWMax = v end
    end
    local p = paramIdxGet('tcp_LabelMeasure')
    if p ~= nil then
      reaper.ThemeLayout_SetParameter(p, trackNamesWMax, true)
      reaper.ThemeLayout_RefreshAll()
    end
  end
end

function measureEnvNames(trackCount)
  for i=0, trackCount do
    local tr = reaper.GetTrack(0, i)
    local trEnvs = reaper.CountTrackEnvelopes(tr)
    if trEnvs > 0 then
      if envs[i] == nil then
        envs[i] = {}
      end
      while #envs[i] > trEnvs do
        table.remove(envs[i])
        redraw = 1
      end
    end
    for j=0, trEnvs-1 do
      local env = reaper.GetTrackEnvelope(tr,j)
      local b, envName = reaper.GetEnvelopeName(env,'')
      gfx.setfont(5) -- ORG name-size auto
      if b == true then
        if envs[i][j+1] ~= nil then
          if envs[i][j+1][name] ~= envName then -- env name has changed
            envs[i][j+1] = {name = envName, l = gfx.measurestr(envName)}
            redraw = 1
          end
        else envs[i][j+1] = {name = envName, l = gfx.measurestr(envName)}
        end
      end
    end
  end
  local envNamesWMax = 100
  for k,v in pairs(envs) do
    if v ~= nil then
      for kk,vv in pairs(v) do
        if vv.l > envNamesWMax then envNamesWMax = vv.l end
      end
    end
  end
  local l = paramIdxGet('envcp_LabelMeasure');
  if l ~= nil then
    reaper.ThemeLayout_SetParameter(l, envNamesWMax, true)
  end
end

------------- ACTIONS --------------

function toggleHelp()
  if _helpR.visible ~= false then doHelpVis(false) else doHelpVis(true) end
end

function doHelpVis(visible)
  if visible == nil then
    if reaper.GetExtState(sTitle,'showHelp') == 'false' then visible = false else visible = true end
  end
  _helpL.visible, _helpR.visible = visible, visible
  _gfxw,_gfxh = table.unpack(_desired_sizes[visible == true and 2 or 1])
  _buttonHelp.img = visible == true and 'help_on' or 'help'
  reaper.SetExtState(sTitle,'showHelp',tostring(visible),true)
  getDpi()
  if _dockedRoot.visible ~= true then
    _gfxw,_gfxh = table.unpack(_desired_sizes[_helpL.visible == true and 2 or 1])
    _gfxw,_gfxh = drawScale_nonmac*_gfxw,drawScale_nonmac*_gfxh
    gfx.init("",_gfxw,_gfxh)
  end
end

function themeName()
  local coltheme = string.match(reaper.GetLastColorThemeFile(), "[^\\/]*$")
  coltheme = string.match(coltheme, "^(.*)%..*$")
  if coltheme and (reaper.file_exists(themes_path.."/"..coltheme..".ReaperThemeZip") or 
    reaper.file_exists(themes_path.."/"..coltheme..".ReaperTheme")) then
    return coltheme
  end
end


function themeCheck()
  local theme, desc, theme_version = reaper.ThemeLayout_GetParameter(0)
  if theme ~= oldTheme or theme == nil then
    last_theme_filename = themeName() or ''
    last_theme_filename_check = reaper.time_precise()
    indexParams()
    _theme.text.str = string.match(last_theme_filename, "[^\\/]*$")
    _theme.text.style = 3
    _theme.w = 362 --math.max(513, gfx.measurestr(_theme.text.str))
    _theme.x = 38
        
    if _csixVersion then  --csix version txt
    if theme ~= 'CSIX' or theme_version < 1 then
    _csixVersion.text.str = '– – –' 
    else
    _csixVersion.text.str = desc or '– – –' end
    end
    
    if theme ~= 'CSIX' or theme_version < 1 then
      _theme.text.str = _theme.text.str .. '\n– script not compatible. Click HERE to reopen CSIX'
      _theme.text.col = {255,102,102} --wrong theme col
    else
      _theme.text.col = {180,180,181} --current theme col
    end

    redraw = 1
    oldTheme = theme
    else
        local now = reaper.time_precise()
        if now > last_theme_filename_check + 1 then
        -- once per second see if the theme filename changed and reload parameters
        last_theme_filename_check = now
        local tfn = themeName()
        if tfn ~= last_theme_filename then
        last_theme_filename = tfn or ''
        
        -- update filename on change
        _theme.text.str = string.match(last_theme_filename, "[^\\/]*$")
        _theme.text.style = 3
        _theme.w = 362 --math.max(513, gfx.measurestr(_theme.text.str))
        _theme.x = 38
                
        -- update csix version txt
        if _csixVersion then
        _csixVersion.text.str = desc or '' end

        paramGet = 1
        redraw = 1
      end
    end
  end
end

function switchToAnyCSIX()
  local str = string.match(reaper.GetLastColorThemeFile(), "^(.*)[/\\].+$")
  local theme_found = false

  local i = 0
  while true do
    local theme_file = reaper.EnumerateFiles(str, i)
    if not theme_file then break end

    if string.match(theme_file, "^CSIX") and 
       (string.match(theme_file, "%.ReaperThemeZip$") or string.match(theme_file, "%.ReaperTheme$")) then
      local theme_path = str.."/"..theme_file
      if reaper.file_exists(theme_path) then
        reaper.OpenColorThemeFile(theme_path)
        theme_found = true
        break  -- Stop after first matching theme
      end
    end
    i = i + 1
  end

  if not theme_found then
    reaper.MB(translate('No theme found with a name starting with \"CSIX\".'), translate('Info:'), 0)
    Quit()
  else
    indexParams()
    redraw = 1
  end
end

function replaceTheme()
  local current_theme_file = reaper.GetLastColorThemeFile()
  
  if string.match(current_theme_file, "[/\\]CSIX") then
    return  -- no replace if already csix*
  end
  local str = string.match(current_theme_file, "^(.*)[/\\].+$")
  local themes_to_check = {
    'CSIX-AE-Narrow-dark_unpacked.ReaperTheme',
    'CSIX-AE-Narrow-dark.ReaperThemeZip',
    'CSIX-DM-Xenon_unpacked.ReaperTheme',
    'CSIX-DM-Xenon.ReaperThemeZip',
    'CSIX-MC-Producer_unpacked.ReaperTheme',
    'CSIX-MC-Producer.ReaperThemeZip',
    'CSIX-BC-Extended_unpacked.ReaperTheme',
    'CSIX-BC-Extended.ReaperThemeZip',
    'CSIX-BASIC-Narrow_unpacked.ReaperTheme',
    'CSIX-BASIC-Narrow.ReaperThemeZip',
    'CSIX-BASIC_unpacked.ReaperTheme',
    'CSIX-BASIC.ReaperThemeZip'}
  local theme_found = false
  for _, theme_file in ipairs(themes_to_check) do
    local theme_path = str.."/"..theme_file
    if reaper.file_exists(theme_path) then
      reaper.OpenColorThemeFile(theme_path)
      indexParams()
      redraw = 1
      theme_found = true
      return
    end
  end
  if not theme_found then
    switchToAnyCSIX()
  end
end

function get_csix_themes() -- csix list
  local themes = { AE = {}, DM = {}, MC = {}, BC = {}, BASIC = {} }
  local current_theme_path = reaper.GetLastColorThemeFile()
  if not current_theme_path or current_theme_path == '' then return themes end

  local theme_dir = current_theme_path:match("^(.*)[/\\].+$")
  local i = 0
  local file = reaper.EnumerateFiles(theme_dir, i)
  while file do
    if file:lower():find("csix") and (file:match("%.ReaperThemeZip$") or file:match("%.ReaperTheme$")) then
      local full = theme_dir .. "/" .. file
      if file:find("^CSIX%-AE") then
        table.insert(themes.AE, { name = file, full = full })
      elseif file:find("^CSIX%-DM") then
        table.insert(themes.DM, { name = file, full = full })
      elseif file:find("^CSIX%-MC") then
        table.insert(themes.MC, { name = file, full = full })
      elseif file:find("^CSIX%-BC") then
        table.insert(themes.BC, { name = file, full = full })
      elseif file:find("^CSIX%-BASIC") then
        table.insert(themes.BASIC, { name = file, full = full })
      end
    end
    i = i + 1
    file = reaper.EnumerateFiles(theme_dir, i)
  end

  for _, list in pairs(themes) do
    table.sort(list, function(a, b) return a.name:lower() < b.name:lower() end)
  end
  return themes
end


function doDock() -- no dock
  local d = 1 --local d = gfx.dock(-1)
  if d%2==0 then
    gfx.dock(d+1)
    _dockedRoot.visible, _undockedRoot.visible = true, false
  else
    gfx.dock(d-1)
    _dockedRoot.visible, _undockedRoot.visible = false, true
  end
  doActivePage()
  resize = 1
  paramGet = 1
end

function getDock()
 local d = gfx.dock(-1)
  if d%2==0 then
    _dockedRoot.visible, _undockedRoot.visible = false, true
  else _dockedRoot.visible, _undockedRoot.visible = true, false
  end
end

function getDpi()
  local newScale, os = 1, reaper.GetOS()
  if gfx.ext_retina and gfx.ext_retina>1.49 then newScale = 2 end

  if os ~= "OSX64" and os ~= "OSX32" and os ~= "macOS-arm64" then
    -- disable (non-macOS) hidpi if window is constrained in height or width
    local minw, minh = 10, 10 --500, 660
    if _dockedRoot and _dockedRoot.visible ~= false then minw, minh = 400, 24 end

    if gfx.h and gfx.w and (gfx.h < minh*newScale or gfx.w < minw*newScale) then newScale = 2 end -- win/retina@2x
    drawScale_nonmac = newScale
    drawScale_inv_nonmac = 1/newScale
  else
    drawScale_inv_mac = 1/newScale
  end

  if newScale ~= drawScale then
    drawScale = newScale
    resize = 1
  end
end

function getEditPageIndex()
  if isGenericTheme == true then
    if editPage2 == 2 then return 4 end
    if editPage2 == 3 then return 6 end
    return 1
  end
  if editPage<1 or editPage>6 then return 1 end
  return editPage
end

function doActivePage()
  local ep = getEditPageIndex()
  if _dockedRoot.visible ~= false then
    for i, v in ipairs(_dockedRoot.children) do
      if i>0 and i<7 then -- ignore the last child (the undock button)
        if i == ep then v.visible = true
        else v.visible = false end
      end
    end
  end

  if _undockedRoot.visible ~= false then
    if isGenericTheme == false and ep == 6 then ep = 5 end
    for i, v in ipairs(_subPageContainer.children) do
      if i>0 and i<=(#_subPageContainer.children) then
        if i == ep then v.visible = true
        else v.visible = false
        end
      end
    end
  end
  resize = 1
end

function doPageSpin(param)
  local val = param[2]

  if val == 0 then return end
  if val > 0 then val = 1 else val = -1 end -- one at a time

  local ep, limit
  if isGenericTheme == true then
    limit = 2
    ep = editPage2
    if _undockedRoot.visible == true then limit = 3 end
  else
    limit = 6
    ep = editPage
    if _undockedRoot.visible == true then limit = 5 end
  end
  
  if ep>=limit and val==1 then
    ep = 1
  else
    if ep==1 and val==-1 then ep = limit
    else ep = ep + val
    end
  end
  if isGenericTheme == true then
    editPage2 = ep
  else
    editPage = ep
  end

  doActivePage()
  needReaperStateUpdate = 1
  paramGet = 1
  root:onSize()
  redraw = 1
end

---------------------------------------------

local lastSelectedTrack = nil

local function getSelectedTrack()
  return reaper.GetSelectedTrack(0, 0)
end

function enforceTcpA(section, layout) --basic narrow tcp A only
  local theme = themeName()
  if section == 'tcp' and type(layout) == 'string' and layout:match('^[BC]') 
     and theme and theme:find('CSIX%-BASIC%-Narrow') then
    return 'A'
  end
  return layout
end

function updateTcpPageOverlay() --basic narrow tcp A only
  local actualTcp = activeLayout.tcp
  local enforcedTcp = enforceTcpA('tcp', actualTcp)
  _tcpPageOverlay.visible = (actualTcp ~= enforcedTcp)
end

function updateTcpBtnOlHelp() --basic narrow tcp A only
  local theme = themeName()
  if theme and theme:find('CSIX%-BASIC%-Narrow') then
    local actualTcp = activeLayout.tcp
    local enforcedTcp = enforceTcpA('tcp', actualTcp)
    _tcpBtnOlHelp.visible = (actualTcp == 'A' and actualTcp == enforcedTcp)
  else
    _tcpBtnOlHelp.visible = false
  end
end

function updateTcpBtnOverlay() --basic narrow tcp A only
  local theme = themeName()
  if theme and theme:find('CSIX%-BASIC%-Narrow') then
    local actualTcp = activeLayout.tcp
    local enforcedTcp = enforceTcpA('tcp', actualTcp)
    _tcpBtnOverlay.visible = (actualTcp == 'A' and actualTcp == enforcedTcp)
  else
    _tcpBtnOverlay.visible = false
  end
end

function doActiveLayout(param)
  function isLayoutName(n)
    if n ~= nil and (n == 'A' or n == 'B' or n == 'C') then return n end
  end
  if param ~= nil then
    local section = param[1]
    local layout = enforceTcpA(section, param[2])  --basic narrow tcp A only
    if isLayoutName(layout) then
      activeLayout[section] = layout
    end
  else
    local tcp = enforceTcpA('tcp', reaper.GetExtState(sTitle, 'activeLayoutTcp')) or 'A'
    local mcp = isLayoutName(reaper.GetExtState(sTitle, 'activeLayoutMcp')) or 'A'
    activeLayout = {
      tcp = isLayoutName(tcp) or 'A',
      mcp = mcp}
  end
  updateTcpPageOverlay()  --basic narrow tcp A only
  updateTcpBtnOlHelp()  --basic narrow tcp A only
  updateTcpBtnOverlay()  --basic narrow tcp A only
  paramGet = 1
  redraw = 1
end

function applyLayout(param) --panel, size
  if param[1] == 'envcp' or param[1] == 'trans' then
    reaper.ThemeLayout_SetLayout(param[1], param[2]..'A')
  else
    local p =  'P_TCP_LAYOUT'
    if param[1] == 'mcp' then p = 'P_MCP_LAYOUT' end
    for i=0, reaper.CountTracks(0)-1 do
      local tr = reaper.GetTrack(0, i)
      if reaper.IsTrackSelected(tr) == true then
        reaper.GetSetMediaTrackInfo_String(tr, p, param[2]..tostring(activeLayout[param[1]]), true)
      end
        needReaperStateUpdate = 1
        updateTrackSound()
    end
  end
end

function reduceCustCol(ifSelected)
  local ratio = 0.4
  local targetR, targetG, targetB = 84,84,84
  reaper.Undo_BeginBlock()
  for i=0, reaper.CountTracks(0)-1 do
    local selState = false
    if ifSelected == true then
      if reaper.IsTrackSelected(reaper.GetTrack(0, i)) == true then
        selState = true
      end
    end
    if (ifSelected ~= true or selState == true) and getCustCol(i)~=nil then
      local r,g,b = getCustCol(i)
      r = math.floor(r * (1-ratio) + targetR * ratio)
      g = math.floor(g * (1-ratio) + targetG * ratio)
      b = math.floor(b * (1-ratio) + targetB * ratio)
      setCustCol(i,r,g,b)
    end
  end
  reaper.Undo_EndBlock('Dimming of custom colors',-1)
end

function resetColorControls()
  for i = -1005, -1000 do
    local ok, _, _, default = reaper.ThemeLayout_GetParameter(i)
    if ok and default then
      reaper.ThemeLayout_SetParameter(i, default, i == -1000)
    end
  end
  paramGet = 1
  colorAdjustFromTheme()  --read color adjust
  redraw = 1
end

function doFader(self,dX)
  if self.userEntry == true then --< the fader's readout
    local name,desc,value,defvalue,minvalue,maxvalue = reaper.ThemeLayout_GetParameter(self.param[1])
    local vValMin, vValMinSuffix = paramToVal(self.param[1],minvalue)
    local vValMax, vValMaxSuffix = paramToVal(self.param[1],maxvalue)
    local r,v = reaper.GetUserInputs(desc, 1, vValMin..vValMinSuffix..' to '..vValMax..vValMinSuffix, self.text.str)
    local val = tonumber(v:match("[-]?[%d.,]+"))
    if r ~= false and val ~= nil then
      local tmp,tmp,tmp,tmp,minvalue,maxvalue = reaper.ThemeLayout_GetParameter(self.param[1])
      val = math.floor(valToParam(self.param[1],val))
      if val < minvalue then val = minvalue end
      if val > maxvalue then val = maxvalue end
      reaper.ThemeLayout_SetParameter(self.param[1], val, true)
      paramGet = 1
      redraw = 1
    end
  else --see fader:mouseDown 
  end
end
function doGenericFader(self,dX)
  doFader(self,dX)
  reaper.ThemeLayout_RefreshAll()
end

--------- CSIX settings management ---------

script_path = ({reaper.get_action_context()})[2]:match("^(.*)[/\\]") .. '/CSIX_theme_adjuster_settings'
themes_path = reaper.GetResourcePath() .. '/ColorThemes'

function showSettingPath()
  local folder = ({reaper.get_action_context()})[2]:match("^(.*)[/\\]") .. '/CSIX_theme_adjuster_settings'
  folder = folder:gsub("\\", "/")
  reaper.RecursiveCreateDirectory(folder, 0)
  local isEmpty = not reaper.EnumerateFiles(folder, 0)
  if isEmpty then
    reaper.MB(translate('No CSIX settings files found.\nUse the Save Buttons to export settings.'), translate('Info:'), 0)
  end
  local open_cmd = ({
    Win = 'start "" ',
    OSX = 'open ',
    default = 'xdg-open '
  })[reaper.GetOS():match("Win") and "Win" or reaper.GetOS():match("OSX") and "OSX" or "default"]
  os.execute(open_cmd .. '"' .. folder .. '"')
end


function ExportParams(exportAll)
  local defaultName = exportAll and 'csixset_all' or 'csixset'
  g_last_exported_name = defaultName

  local retval, title = reaper.GetUserInputs(
    translate('Save Settings'), 1, translate('Filename for settings to save:, extrawidth=50'), 
    g_last_exported_name)
  if not retval or not title or title:match("^%s*$") then
    return  -- User canceled
  end

  local settings_folder = script_path
  reaper.RecursiveCreateDirectory(settings_folder, 0)

  local exportFilename = settings_folder .. "/" .. title .. '.csixsetting'
  local existing = io.open(exportFilename, "r")
  if existing then
    existing:close()
    local fileNameOnly = exportFilename:match("[^/\\]+$")
    local button = reaper.MB(translate(fileNameOnly .. '\r\n\r\nThe file already exists and will be updated\r'
    .. 'with the current theme settings.\n'), translate('Overwrite?'), 1)
    if button ~= 1 then
      return
    end
  end

  local file = io.open(exportFilename, "w")
  if not file then
    reaper.MB(translate('Error writing to:\r\n\r\n\t') .. exportFilename, translate('Error'), 0)
    return
  end

  g_last_exported_name = title
  local i = -1005
  while true do
    local retval, desc, val, def = reaper.ThemeLayout_GetParameter(i)
    if not retval then break end

    local masterRGB =
      desc == 'A_masterColor_r' or
      desc == 'A_masterColor_g' or
      desc == 'A_masterColor_b'

    if exportAll or masterRGB or (val ~= def) then
      file:write(desc .. '=' .. val .. '\n')
    end

    if i == -1000 then
      i = 0
    else
      i = i + 1
    end
  end
  file:close()
  -- reaper.MB(translate('File path:\r\n\r\n') .. exportFilename, translate('Settings saved'), 0)
end

function exportParams()      ExportParams(false) end
function exportParamsAll()   ExportParams(true)  end


function importParams()
  local script_path = ({reaper.get_action_context()})[2]:match("^(.*)[/\\]")
  script_path = script_path:gsub("\\", "/")  -- win
  local folder = script_path .. '/CSIX_theme_adjuster_settings'
  reaper.RecursiveCreateDirectory(folder, 0)

  local dummy_file = folder .. '/_.csixsetting'
  local retval, importFile = reaper.GetUserFileNameForRead(dummy_file, '/CSIX_theme_adjuster_settings/', '*.csixsetting', 'csixsetting')
  if retval then
    g_last_exported_name = importFile:match(".*[/\\](.*)%..+")
    for line in io.lines(importFile) do
      local param, val = line:match("(.+)=(.+)")
      if param and val then
        val = tonumber(val)
        if val then
          local pIdx
          local layout, paramName = param:match("([ABC])_(.+)")
          if layout and paramName then
            if paramsIdx[layout] and paramsIdx[layout][paramName] then
              pIdx = paramsIdx[layout][paramName]
            end
          elseif param == 'Gamma' then
            pIdx = -1000
          elseif param == 'Highlights' then
            pIdx = -1003
          elseif param == 'Midtones' then
            pIdx = -1002
          elseif param == 'Shadows' then
            pIdx = -1001
          elseif param == 'Saturation' then
            pIdx = -1004
          elseif param == 'Tint' then
            pIdx = -1005
          else
            pIdx = paramsIdx.global[param]
          end
          if pIdx then
            reaper.ThemeLayout_SetParameter(pIdx, val, true)
            reaper.ThemeLayout_RefreshAll()
            end
        end
    end
end
    reaper.MB(translate('Please note that available features and settings\r'
    .. 'are different between the CSIX Series.'), translate('Import Successful'), 0)
    end
end


function importCsixSet()
  local importFile = script_path .. '/csixset.csixsetting'
  if not reaper.file_exists(importFile) then
    reaper.MB(translate('The default \"csixset\" settings file does not exist.\r\n\r\n'
    .. 'Use Save Changes to create a default preset\nwith the name \"csixset\".\n'), translate('Info:'), 0)
    return
  end

  g_last_exported_name = 'csixset'
  for line in io.lines(importFile) do
    local param, val = line:match("(.+)=(.+)")
    if param and val then
      val = tonumber(val)
      if val then
        local pIdx
        local layout, paramName = param:match("([ABC])_(.+)")
        if layout and paramName then
          if paramsIdx[layout] and paramsIdx[layout][paramName] then
            pIdx = paramsIdx[layout][paramName]
          end
        elseif param == 'Gamma' then
          pIdx = -1000
        elseif param == 'Highlights' then
          pIdx = -1003
        elseif param == 'Midtones' then
          pIdx = -1002
        elseif param == 'Shadows' then
          pIdx = -1001
        elseif param == 'Saturation' then
          pIdx = -1004
        elseif param == 'Tint' then
          pIdx = -1005
        else
          pIdx = paramsIdx.global[param]
        end
        if pIdx then
          reaper.ThemeLayout_SetParameter(pIdx, val, true)
          reaper.ThemeLayout_RefreshAll()
        end
      end
    end
  end
  reaper.MB(translate('Theme settings \"csixset\" imported.'), translate('Import Successful'), 0)
end


function importCsixSetAll()
  local importFile = script_path .. '/csixset_all.csixsetting'
  if not reaper.file_exists(importFile) then
    reaper.MB(translate('The default \"csixset_all\" settings file does not exist.\r\n\r\n'
    .. 'Use Save All Settings to create a default preset\nwith the name \"csixset_all\".\n'), translate('Info:'), 0)
    return
  end

  g_last_exported_name = 'csixset_all'
  for line in io.lines(importFile) do
    local param, val = line:match("(.+)=(.+)")
    if param and val then
      val = tonumber(val)
      if val then
        local pIdx
        local layout, paramName = param:match("([ABC])_(.+)")
        if layout and paramName then
          if paramsIdx[layout] and paramsIdx[layout][paramName] then
            pIdx = paramsIdx[layout][paramName]
          end
        elseif param == 'Gamma' then
          pIdx = -1000
        elseif param == 'Highlights' then
          pIdx = -1003
        elseif param == 'Midtones' then
          pIdx = -1002
        elseif param == 'Shadows' then
          pIdx = -1001
        elseif param == 'Saturation' then
          pIdx = -1004
        elseif param == 'Tint' then
          pIdx = -1005
        else
          pIdx = paramsIdx.global[param]
        end
        if pIdx then
          reaper.ThemeLayout_SetParameter(pIdx, val, true)
          reaper.ThemeLayout_RefreshAll()
        end
      end
    end
  end
  reaper.MB(translate('Theme settings \"csixset_all\" imported.'), translate('Import Successful'), 0)
end


local ini_path = reaper.GetResourcePath() .. '/reaper-themeconfig.ini'

function wipeThemeParams()
  local f = io.open(ini_path, "r")
  if not f then
    return reaper.ShowMessageBox(translate('Could not open reaper-themeconfig.ini for reading.'), translate('Error'), 0)
  end
  local lines = {}
  local themes = get_csix_themes()
  local csix_names = {}

  for _, list in pairs(themes) do
    for _, t in ipairs(list) do
      local name = t.name:gsub("%.ReaperThemeZip$", ""):gsub("%.ReaperTheme$", "")
      csix_names[name] = true
    end
  end

  local in_section = false
  local current_section = nil

  for line in f:lines() do
    local section = line:match("^%[(.+)%]$")
    if section then
      current_section = section
      in_section = csix_names[section] or false
      table.insert(lines, line)
    elseif not in_section or not line:match("^param%d+=") then
      table.insert(lines, line)
    end
  end
  f:close()

  local f_out = io.open(ini_path, "w")
  if not f_out then
    return reaper.ShowMessageBox(translate('Could not open reaper-themeconfig.ini for writing.'), translate('Error'), 0)
  end
  f_out:write(table.concat(lines, "\n") .. "\n")
  f_out:close()
end


function wipeSaveAllSettings()
  local settings_folder = script_path
  local deleted_files = {}

  local function tryDelete(filename)
    local fullPath = settings_folder .. "/" .. filename
    local file = io.open(fullPath, "r")
    if file then
      file:close()
      os.remove(fullPath)
      table.insert(deleted_files, filename)
    end
  end
--tryDelete('csixset.csixsetting') --keep this for now
  tryDelete('csixset_all.csixsetting') --remove Merge settings
end


function resetCurrent()
    if reaper.MB(translate('Resets the current ReaperTheme and reloads\nthe theme with its default values.\n'), 
    translate('Reset Theme:'), 1) == 1 then
    for i=-1005,-1000,1 do
    local retval,tmp,val,d = reaper.ThemeLayout_GetParameter(i)
    retval,tmp,val,d = reaper.ThemeLayout_GetParameter(i)
    while retval ~= nil do
    if val~=d then reaper.ThemeLayout_SetParameter(i, d, true) end
    if i==-1000 then i=0 end
    i = i+1
    retval,tmp,val,d = reaper.ThemeLayout_GetParameter(i, 0) end
    
    end
      local themePath = reaper.GetLastColorThemeFile()
      reaper.OpenColorThemeFile(themePath)
      reaper.ThemeLayout_RefreshAll()
      paramGet = 1
      redraw = 1
    end
    local theme = themeName()
end


function totalReset()
    if reaper.MB(translate('Removes ALL changes for installed CSIX Series\nincluding the default preset \"csixset_all\" used\nfor Merging.\r\n\r\n'
    .. 'Reloads the current theme with its default values.\r\n\r\n'
    .. 'Cleans up excess CSIX data in root file:\r\nreaper-themeconfig.ini\n'), translate('Total Reset:'), 1) == 1 then
    for i=-1005,-1000,1 do
    local retval,tmp,val,d = reaper.ThemeLayout_GetParameter(i)
    retval,tmp,val,d = reaper.ThemeLayout_GetParameter(i)
    while retval ~= nil do
    if val~=d then reaper.ThemeLayout_SetParameter(i, d, true) end
    if i==-1000 then i=0 end
    i = i+1
    retval,tmp,val,d = reaper.ThemeLayout_GetParameter(i, 0) end
    
    wipeThemeParams()
    wipeSaveAllSettings()
    end
      local themePath = reaper.GetLastColorThemeFile()
      reaper.OpenColorThemeFile(themePath)
      reaper.ThemeLayout_RefreshAll()
      paramGet = 1
      redraw = 1
    end
    local theme = themeName()
    -- reaper.ShowMessageBox(translate('Wiped parameter entries from:\r\n[' .. theme .. ']\r\n\r\n'
    -- .. 'in root file: reaper-themeconfig.ini'), translate('Info:'), 0)
    -- reaper.ShowMessageBox(translate('Wiped parameter entries from root file:\r\nreaper-themeconfig.ini'), translate('Info:'), 0)
end


function open_url_csix()
  local url = "https://additive.audio/csix"
  local message = translate('Check for updates and read the latest news.\nDiscover useful tips for using CSIX.\n\n') .. url .. '\r\n'
  if reaper.MB(message, translate('Visit CSIX website?'), 1) == 1 then
    if package.config:sub(1, 1) == '\\' then
      os.execute('start "" "' .. url .. '"')
    elseif (io.popen("uname -s"):read('*a')):match('Darwin') then
      os.execute('open "' .. url .. '"')
    else
      os.execute('xdg-open "' .. url .. '"')
    end
  end
end

function csixList(mergeMode) -- themes dropdown list
  local theme_groups = get_csix_themes()
  local group_order = { 'AE', 'DM', 'MC', 'BC', 'BASIC' }
  local group_titles = {
    AE    = 'AE Series',
    DM    = 'DM Series',
    MC    = 'MC Series',
    BC    = 'BC Series',
    BASIC = 'BASIC',
  }

  local menu_items = {}
  table.insert(menu_items, { type='|', label='Available CSIX Themes:' })
  local current_theme = themeName()
  for _, key in ipairs(group_order) do
    local group = theme_groups[key]
    if #group > 0 then
      table.insert(menu_items, { type='|', label='|#  ' .. group_titles[key] .. ' ' })
      for _, t in ipairs(group) do
        local base = t.name:match("(.+)%..+$") or t.name
        local bullet = (base == current_theme) and '• ' or '  '
        table.insert(menu_items, { type='theme', data=t, label=bullet .. base })
      end
    end
  end

  local menu_str = ''
  for i, entry in ipairs(menu_items) do
    local prefix = (entry.type == '|') and '#' or ''
    menu_str = menu_str .. ((i > 1) and '|' or '') .. prefix .. entry.label
  end

  local x, y = gfx.mouse_x, gfx.mouse_y
  gfx.x, gfx.y = x, y
  local mouse_cap = gfx.mouse_cap
  local selection = gfx.showmenu(menu_str)

  if selection > 0 then
    local selected_theme = menu_items[selection]
    if selected_theme and selected_theme.type == 'theme' then
      if mergeMode and mouse_cap == 16 then -- hold ALT to save All (merge mode)
        exportParamsAll()
      end

      reaper.OpenColorThemeFile(selected_theme.data.full)
      indexParams()

      if mergeMode then
        local importFile = script_path .. '/csixset_all.csixsetting'
        if reaper.file_exists(importFile) then
          importCsixSetAll()
        else
          reaper.MB(translate('No preset named "csixset_all" was found.\nThe loaded theme will use its previous settings.\r\n\r\n'
            .. 'Tip:\nHold ALT to Save All before using Merge mode.\n'), translate('Theme not Merged'), 0)
        end
      end
    end
  end
    updateTcpPageOverlay()  --basic narrow tcp A only
    updateTcpBtnOlHelp()  --basic narrow tcp A only
    updateTcpBtnOverlay()  --basic narrow tcp A only
    needReaperStateUpdate = 1
end
function csixListSwitch()  csixList(false) end
function csixListMerge()  csixList(true) end


function csix_layout_list()
    local sections = {'global','tcp','master_tcp','envcp','mcp','master_mcp','trans'}
    local layoutMap = {} -- [menu index] = {section, layoutIdx}
    local menu_str = '#Available Layouts:|'

    local displayIndex = 1
    for _, section in ipairs(sections) do
        local _, currentLayout = reaper.ThemeLayout_GetLayout(section, -1)
        local sectionHasLayouts = false
        local section_menu = '|'

        local i = 0
        while true do
            local ok, name = reaper.ThemeLayout_GetLayout(section, i)
            if not ok then break end

            local name_list = (name or ''):lower()
            local is_blank_or_default = name_list:match("^%s*$") or name_list:match('default')
            local displayName = is_blank_or_default and 'standard A' or name
            if not name:match('~2x_') then
                sectionHasLayouts = true
                displayIndex = displayIndex + 1
                local current_list = (currentLayout or ''):lower()
                local isCurrent = (name == currentLayout)
                or (is_blank_or_default and (not currentLayout or current_list:match("^%s*$") or current_list:match('default')))

                local prefix = isCurrent and '• ' or '  '
                local label = prefix .. section:upper() .. ': ' .. displayName
                section_menu = section_menu .. label .. '|'
                layoutMap[displayIndex] = {section = section, index = i}
                --reaper.ShowConsoleMsg(label .. '\n')
            end
            i = i + 1
        end
        if sectionHasLayouts then
            menu_str = menu_str .. section_menu
        end
        needReaperStateUpdate = 1
    end

    local x, y = gfx.mouse_x, gfx.mouse_y
    gfx.x, gfx.y = x, y
    local selection = gfx.showmenu(menu_str)
    if layoutMap[selection] then
        local layout = layoutMap[selection]
        local _, layoutName = reaper.ThemeLayout_GetLayout(layout.section, layout.index)
        reaper.ThemeLayout_SetLayout(layout.section, layoutName)
    end
end


--------- ARRANGE ELEMENTS ---------

function Element:onSize()

  local crop = self.crop or false
  if self.children ~= nil and self.visible ~= false and self.crop ~= true then
    for i, v in ipairs(self.children) do

      local bx,by = 0,0
      if v.border == 'xy' or v.border == 'x' then bx = globalBorderX end
      if v.border == 'xy' or v.border == 'y' then by = globalBorderY end

      local prevElX, prevElY, prevElW, prevElH = 0,0,0,0
      if i>1 then --there is a previous child
        prevElX, prevElY, prevElW, prevElH = self.children[i-1].drawx, self.children[i-1].drawy, self.children[i-1].drawW, self.children[i-1].drawH
        if self.children[i-1].visible == false then prevElW = 0 end
      end

      if v.flexW ~= nil then
        if v.flexW == 'fill' then
          v.drawW = self.drawx + (self.drawW or self.w) - ((prevElX or self.drawx) + (prevElW or 0)) + (v.w or 0)
        else v.drawW = (v.w or 0) + ((self.drawW or self.w) * (v.flexW:sub(1, -2) / 100))
        end
      else v.drawW = v.w
      end

      if v.flexH ~= nil then v.drawH = (v.h or 0) + ((self.drawH or self.h) * (v.flexH:sub(1, -2) / 100))
      else v.drawH = v.h end

      v:position(self.drawx,self.drawy,self.drawW,self.drawH,prevElX, prevElY, prevElW, prevElH, bx, by)
      v:onSize() -- this child sizes its children

    end
  end
end

function Element:position(parentX,parentY,parentW,parentH,prevElX, prevElY, prevElW, prevElH, bx, by)

  if parentX == nil then parentX = 0 end
  if parentY == nil then parentY = 0 end
  if parentW == nil then parentW = 0 end
  if parentH == nil then parentH = 0 end
  self.drawx, self.drawy = parentX  + self.x + bx, parentY + self.y + by

  if self.positionX ~= nil then
    if self.positionX == 'center' then
      parentW, parentH = parentW * drawScale_inv_nonmac, parentH * drawScale_inv_nonmac
      self.drawx, self.drawy = (parentW - self.drawW)/2, (parentH - self.drawH)/2
    elseif self.positionX == 'right' then
      self.drawx = parentW - self.w
    end
  end

  if self.flow ~= nil and self.flow ~= false then
    if prevElX == nil or prevElW == 0 then  -- you're the first child
      self.drawx, self.drawy = parentX + self.x + bx, parentY + self.y + by
      self.crop = false
      if (parentX + parentW) < (self.drawx + self.drawW + bx) then
        self.crop = true
      end
    else  -- there is a previous child
      if (prevElX + prevElW + bx + self.drawW + bx) <= (parentX + parentW) then  -- place you as next element
        self.drawx, self.drawy = prevElX + prevElW + bx + self.x, prevElY + self.y
        self.debug = 'prevElX : '..prevElX..'    prevElW : '..prevElW..'    prevElY : '..prevElY
        self.crop = false
      elseif (parentY + parentH) > (prevElY + prevElH + self.y + self.drawH + by) then  -- flow you to next row
        self.drawx, self.drawy = parentX + self.x + globalBorderX, prevElY + prevElH + self.y + globalBorderY
        self.debug = 'FLOW! prevElX : '..prevElX..'    prevElW : '..prevElW..'    prevElY : '..prevElY
        self.crop = false
       else
        self.crop = true  -- don't fit, crop you
      end
    end

  end
  self.crop = false
end


  ---------- DRAW -----------

function Element:draw()

  gfx.set(0,0,0,1) -- opacity reset
  local crop = self.crop or false
  if self.debug == true then debugTable(self) end
  if self.visible ~= false and crop ~= true then
    local thisX = drawScale * (self.drawx or self.x)
    local thisY = drawScale * (self.drawy or self.y)
    local thisW = drawScale * (self.drawW or self.w or 0)
    local thisH = drawScale * (self.drawH or self.h or 0)
    local thisDrawW = drawScale * (self.drawW or 0)
    local thisDrawH = drawScale * (self.drawH or 0)

    local thisCol = self.drawColor or self.color or nil
    if thisCol ~= nil then
      setCol(thisCol)
      if self.shape == nil then
        gfx.rect(thisX,thisY,thisDrawW,thisDrawH)
      else 
        local r = thisDrawW/2
        gfx.circle(thisX+r,thisY+r,r,true)
      end
    end

    if self.img ~= nil or  self.valsImage ~= nil then
      local img = self.img or self.valsImage
      if self.drawImg ~= nil then -- then this element's image isn't static
        img = self.drawImg
      end
      local i = getImage(img,drawScale)
        local iDw, iDh = gfx.getimgdim(i)

      if self.imgType ~= nil and iDw ~= nil and self.imgType == 3 then
        local yOffset = 0
        if thisW ~= iDw/3 then -- width stretching needed
          local pad = drawScale * 10
          gfx.blit(i, 1, 0, (iDw/3)*(self.imgFrame or 0), 0, pad, iDh, thisX, thisY, pad, iDh)
          gfx.blit(i, 1, 0, ((iDw/3)*(self.imgFrame or 0))+ pad, 0, (iDw / 3) -(2*pad), iDh, thisX+pad, thisY, thisW-(2*pad), iDh)
          gfx.blit(i, 1, 0, (iDw/3)*(self.imgFrame or 0) + (iDw/3 -pad), 0, pad, iDh, thisX + thisW-pad, thisY, pad, iDh)
        else
          gfx.blit(i, 1, 0, (iDw/3)*(self.imgFrame or 0), 0, iDw / 3, iDh, thisX, thisY, iDw / 3, iDh)
        end
      elseif self.valsImage ~= nil then
        gfx.blit(i, 1, 0, thisW*(self.imgValueFrame or 0), 0, thisW, iDh, thisX, thisY, thisW, iDh)
      else
        gfx.blit(i, 1, 0, 0, 0, iDw, iDh, thisX, thisY, thisDrawW, thisDrawH)
      end
    end

    if self.text ~= nil then
      if self.text.val ~=nil then
        self.text.str = self.text.val()
      end
    local txtScaleOffs = ''
    if drawScale == 2 then txtScaleOffs = 1 end
      local tx,tw = thisX + (drawScale*textPadding), thisW - 2*(drawScale*textPadding)
      text(self.text.str,tx,thisY,tw,thisDrawH,self.text.align,self.text.col,txtScaleOffs..(self.text.style or 1),self.text.lineSpacing,self.text.vCenter,self.text.wrap)
    end

    drawChildren(self.children)
  end
end

function Palette:draw()
  local crop = self.crop or false
  if self.visible ~= false and crop ~= true then
    local p = getCurrentPalette()
    for i, v in ipairs(self.children) do
      v.color = palette[p][i]
      v.param = palette[p][i]
    end
    drawChildren(self.children)
  end
end

function drawChildren(ch)
  if ch ~= nil then
    for i, v in ipairs(ch) do
      v:draw() -- this box draws its children
    end
  end
end


local function parseLayoutChar(val, fallback)
  if not val or val:match("^%s*$") or val:lower():match("default") then
    return fallback
  end
  if val:lower():match("title%-track") then
    return 'A'
  end
  local dpiMatch = val:match("[^_]+_([ABC])$")  --Remove any dpi prefix
  if dpiMatch then return dpiMatch end
  local bracket = val:match("%[([ABC])%]")
  local firstChar = val:sub(1, 1)
  if bracket == 'A' or bracket == 'B' or bracket == 'C' then
    return bracket
  elseif firstChar == 'A' or firstChar == 'B' or firstChar == 'C' then
    return firstChar
  else
    return fallback
  end
end


function getTrackSoundState(layout, section, threshold)
  threshold = threshold or 0.0000001
  local param = (section == 'mcp') and 'P_MCP_LAYOUT' or 'P_TCP_LAYOUT'

  local fallback = 'A'
  local _, defaultLayout = reaper.ThemeLayout_GetLayout(section, -1)
  fallback = parseLayoutChar(defaultLayout, fallback)

  for i = 0, reaper.CountSelectedTracks(0) - 1 do
    local track = reaper.GetSelectedTrack(0, i)
    if track then
      local _, val = reaper.GetSetMediaTrackInfo_String(track, param, "", false)
      local layoutChar = parseLayoutChar(val, fallback)

      if layoutChar == layout then
        local l = reaper.Track_GetPeakInfo(track, 0)
        local r = reaper.Track_GetPeakInfo(track, 1)
        if l > threshold or r > threshold then return 1 end
      end
    end
  end
  return 0
end

function updateTrackSound()
  for i, btn in ipairs(_trackSound) do
    if btn.visible ~= false and btn.action == doTrackSound then
      btn.action(btn)
    end
  end
end

function doTrackSound(self)
  if not self or not self.param then return end
  local signal = getTrackSoundState(self.param[2], self.param[1], 0.0000001)
  local old = self.signalState or 0
  self.signalState = signal

  self.drawImg = (signal == 1) and (self.img .. '_on') or nil
  if signal ~= old then redraw = 1 end

  if self.children then
    for _, child in ipairs(self.children) do
      if child.visible ~= false and child.doTrackSound then
        child:doTrackSound()
      end
    end
  end
end


function anySelected(self)
  if self.text and self.text.colFalse and needReaperStateUpdate == 1 then
    local section = self.getParam[1]  --tcp or mcp
    local targetLayout = self.getParam[2]  --ABC
    local param = (section == 'mcp') and 'P_MCP_LAYOUT' or 'P_TCP_LAYOUT'
    self.text.col = self.text.colFalse

    local _, defaultLayout = reaper.ThemeLayout_GetLayout(section, -1)
    local fallback = parseLayoutChar(defaultLayout, 'A')

    local tracks = {}
    for i = 0, reaper.CountTracks(0) - 1 do
      local tr = reaper.GetTrack(0, i)
      if reaper.IsTrackSelected(tr) then
        table.insert(tracks, { track = tr, isMaster = false })
      end
    end
    local master = reaper.GetMasterTrack(0)
    if reaper.IsTrackSelected(master) then
      table.insert(tracks, { track = master, isMaster = true })  --check for master
    end

    for _, entry in ipairs(tracks) do
      local track = entry.track
      local isMaster = entry.isMaster
      local _, layoutVal = reaper.GetSetMediaTrackInfo_String(track, param, "", false)
      local layoutChar = parseLayoutChar(layoutVal, isMaster and 'A' or fallback)  --A if master

      if layoutChar == targetLayout then
        self.text.col = self.text.colTrue
        activeLayout[section] = layoutChar  --update activeLayout
        paramGet = 1
        break
      end
    end
  end
end


function isDefault(self)
  local section = self.getParam[1]
  local target = self.getParam[2]
  local _, def = reaper.ThemeLayout_GetLayout(section, -1)
  local layoutChar = parseLayoutChar(def, 'A')

  if self.text and self.text.colFalse then
    local oldcol = self.text.col
    self.text.col = (layoutChar == target) and self.text.colTrue or self.text.colFalse
    if oldcol ~= self.text.col then redraw = 1 end
  end
end

  --------- MOUSE ---------
  
function Element:mouseOver()
  if self.moColor ~= nil then 
    self.moColorOff, self.color = self.col, self.moColor
    redraw = 1
  end
end

function Element:mouseAway()
  if self.imgFrame ~= nil then
    self.imgFrame = 0
  end
  if self.moColor ~= nil then
    self.color, self.moColorOff = self.moColorOff, nil
  end
  _helpL.y, _helpR.y = 10000,10000
  redraw = 1
end

function Element:mouseDown(x,y) end 
function Element:mouseUp(x,y) end
function Element:doubleClick() end

function Element:mouseWheel(v)
  if self.action ~= nil and type(self.param) == 'table' then
    self.action({self.param[1],v})
    root:doUpdateState() -- doing a complete root:doUpdateState because other buttons might have changed state as a result of my actions.
    root:doParamGet()
    redraw = 1
  end
end

function Button:mouseOver()
  if self.img ~= nil then
    if self.imgType ~= nil and self.imgType == 3 and self.imgFrame ~= 1 then
      self.imgFrame = 1
      redraw = 1
    end
  end
end

function Fader:mouseOver()
  if self.img ~= nil then
    if self.imgType ~= nil and self.imgType == 3 and self.imgFrame ~= 1 then
      self.imgFrame = 1
      redraw = 1
    end
  end
end

function Element:mouseDown(x,y) end 
function Element:mouseUp(x,y) end
function Element:doubleClick() end

local lastClickTime = 0
local lastClickedElement = nil
local DOUBLE_CLICK_TIME = 0.3

function Element:mouseWheel(v)
  if self.action ~= nil and type(self.param) == 'table' then
    self.action({self.param[1],v})
    root:doUpdateState() -- doing a complete root:doUpdateState because other buttons might have changed state as a result of my actions.
    root:doParamGet()
    redraw = 1
  end
end

function Button:mouseOver()
  if self.img ~= nil then
    if self.imgType ~= nil and self.imgType == 3 and self.imgFrame ~= 1 then
      self.imgFrame = 1
      redraw = 1
    end
  end
end

function Fader:mouseOver()
  if self.img ~= nil then
    if self.imgType ~= nil and self.imgType == 3 and self.imgFrame ~= 1 then
      self.imgFrame = 1
      redraw = 1
    end
  end
end

function Fader:mouseDown(x,y)
  local name,desc,value,defvalue,minvalue,maxvalue = reaper.ThemeLayout_GetParameter(self.param)
  if self.dragStart == nil then
    self.dragStart = x
    self.dragStartValue = value
  end
  local dX = x - self.dragStart
  
  if dX ~= 0 then
    local v = math.floor(dX * ((maxvalue - minvalue)/(352 * drawScale)))
    local newValue = math.max(math.min(self.dragStartValue + v,maxvalue),minvalue)
    if newValue ~= value then
      reaper.ThemeLayout_SetParameter(self.param, newValue,false)
      ctheme_param_needsave = { self.param }
      self:doUpdateState()
      self.parent:onSize()
      if self.onChange ~= nil then self:onChange() end
      if self.readout ~= nil then self.readout:doParamGet() end
      redraw = 1
    end
  end
end

function FaderBg:mouseDown(x,y)
  local tmp,tmp,value,tmp,minvalue,maxvalue = reaper.ThemeLayout_GetParameter(self.param)
  local v = minvalue + math.floor(((x/drawScale-self.drawx-10)/352)*(maxvalue-minvalue))
  v = math.max(math.min(v,maxvalue),minvalue)
  if v ~= value then
    reaper.ThemeLayout_SetParameter(self.param,v,false)
    ctheme_param_needsave = { self.param }
    self:doUpdateState()
    self.parent:onSize()
    if self.onChange ~= nil then self:onChange() end
    if self.readout ~= nil then self.readout:doParamGet() end
    redraw = 1
  end
end

function Fader:doubleClick() 
  local tmp,title,value,defValue = reaper.ThemeLayout_GetParameter(self.param)
  reaper.ThemeLayout_SetParameter(self.param,defValue, true)
  ctheme_param_needsave = nil
  if self.onChange ~= nil then self:onChange() end
  if self.readout ~= nil then self.readout:doParamGet() end
end

function Fader:mouseWheel(v)
  local tmp,tmp,value,tmp,minvalue,maxvalue = reaper.ThemeLayout_GetParameter(self.param)
  newValue = value + v
  if newValue < minvalue then newValue = minvalue end
  if newValue > maxvalue then newValue = maxvalue end
  reaper.ThemeLayout_SetParameter(self.param, newValue, false)
  ctheme_param_needsave = { self.param, reaper.time_precise() + .5 }
  self:doUpdateState()
  self.parent:onSize()
  if self.onChange ~= nil then self:onChange() end
  if self.readout ~= nil then self.readout:doParamGet() end
  redraw = 1
end

FaderBg.mouseWheel = Fader.mouseWheel

function Readout:doubleClick()
  if self.userEntry == true then
    self.action(self)
    root:doUpdateState()
    resize = 1
    paramGet = 1
    if self.onChange ~= nil then self:onChange() end
    return
  end
  if not self.param or not self.param[1] then return end --update theme
  local p = paramIdxGet(self.param[1])
  if not p then return end
  local retval, desc, value, def = reaper.ThemeLayout_GetParameter(p)
  if retval and def ~= nil and value ~= def then
    reaper.ThemeLayout_SetParameter(p, def, true)
    reaper.ThemeLayout_RefreshAll()
    self:doParamGet()
    paramGet = 1
    redraw = 1
  end
end

function doHelp()
  if _undockedRoot.visible ~= false then
    local help_hit = root:hitTestHelp(gfx.mouse_x,gfx.mouse_y);
    if lastHelpElem ~= help_hit then
      if help_hit ~= nil and help_hit.helpL ~= nil then
        _helpL.y = math.max((help_hit.drawy or help_hit.y) - 36,80)
        _helpL.text.str = help_hit.helpL
      end
      if help_hit ~= nil and help_hit.helpR ~= nil then
        _helpR.y = math.max((help_hit.drawy or help_hit.y) - 36,80)
        _helpR.text.str = help_hit.helpR
      end
      resize = 1
      lastHelpElem = help_hit
    end
  end
end
function Button:mouseUp()
  if self.img ~= nil then
    if self.imgType ~= nil and self.imgType == 3 then
      self.imgFrame = 2
    end
  end
  if self.action ~= nil then self.action(self.param) end
  root:doUpdateState() -- doing a complete root:doUpdateState because other buttons might have changed state as a result of my actions.
  paramGet = 1
  redraw = 1
end

function SwatchHitbox:mouseOver()
  self.parent.children[12].color = {180,180,181}
  self.parent.children[13].text.col = {180,180,181}
end

function SwatchHitbox:mouseUp()
  palette.current = self.paletteIdx
  paramGet = 1
  redraw = 1
end

function SwatchHitbox:mouseAway()
  self.parent:doParamGet()
end

function Element:hitTest(x,y)
  local thisX, thisY, thisW, thisH = self.drawx or self.x, self.drawy or self.y, self.drawW or self.w or 0, self.drawH or self.h
  local xS,yS = x / drawScale, y / drawScale
  if self.visible ~= false then
    local inrect = xS >= thisX and yS >= thisY and xS < thisX + thisW and yS < thisY + thisH
    if self.children ~= nil and (inrect == true or self.has_children_outside == 1) then
      for i,v in pairs(self.children) do
        local s = v:hitTest(x,y)
        if s ~= nil then return s end
      end
    end
    if inrect and (self.interactive ~= false or self.helpL ~= nil or self.helpR ~= nil) then
      return self
    end
  end
  return nil
end

function Element:hitTestHelp(x,y)
  local thisX, thisY, thisW, thisH = self.drawx or self.x, self.drawy or self.y, self.drawW or self.w or 0, self.drawH or self.h
  local xS,yS = x / drawScale, y / drawScale
  if self.visible ~= false then
    local inrect = xS >= thisX and yS >= thisY and xS < thisX + thisW and yS < thisY + thisH
    if self.children ~= nil and (inrect == true or self.has_children_outside == 1) then
      for i,v in pairs(self.children) do
        local s = v:hitTestHelp(x,y)
        if s ~= nil then return s end
      end
    end
    if inrect and (self.helpL ~= nil or self.helpR ~= nil) then
      return self
    end
  end
  return nil
end

function Element:mouseUp()
  local now = reaper.time_precise()
  if lastClickedElement == self and (now - lastClickTime) < DOUBLE_CLICK_TIME then
    if type(self.onDoubleClick) == 'function' then
      self:onDoubleClick()
    end
  end
  lastClickTime = now
  lastClickedElement = self
end

-- Spinner label values
menuBoxVals = {'GLOBAL','TRACK','MIXER','COLORS','ENVELOPE','TRANSPORT'}
folderIndentVals = {'NONE','1/8','1/4','1/2',1,2,3}
tcpLabelVals = {'AUTO',20,50,80,110,140,170}
tcpVolVals = {'KNOB',40,70,100,130,160,170}
tcpMeterVals = {'HIDE',1,2,3,4,5,6,7,8,'MAX'}
tcpInVals = {'MIN',25,40,60,90,150,200}
mcpMeterExpVals = {'NONE',2,4,8}
envcpLabelVals = {'AUTO',20,50,80,110,140,170}
transRateVals = {'KNOB',80,130,160,200,250,310,380}
transMetroBtnVals = {'NONE','METRONOME','REGION SEEK','ALL'}
transActBtnVals = {'NONE','Sec. A','Sec. B / A','Sec. C / B / A','Sec. D* / C / B / A'}
mcpBorderVals = {'NONE', 'LEFT EDGE', 'RIGHT EDGE', 'ROOT FOLDERS', 'AROUND FOLDERS'}
dockedMcpMeterExpVals = {'NONE','+ 2 PIXELS','+ 4 PIXELS','+ 8 PIXELS'}
undockPaletteNamesVals = {'LUNA','STRONG','MOCHA','TRENDY','BEACH','KITTY','FESTIVAL','GAMUT','FLOW1','FLOW2'}
controlAlignVals = {'FOLDER INDENT','ALIGNED','EXTEND NAME'}
trackControlAlignVals = {'FOLDER INDENT','ALIGNED','EXTEND NAME'}
tcpCustomButtonVals = {'w < 400','w < 500','w < 600','ALWAYS','w < 260 (AE)','w < 400 (AE)','w < 500 (AE)'}
tcpParmVisVals = {'Show','Show if Sel.','Hide'}
seperateSendsVals = {'Hide List','On/Stretch','Fixed','Stepped'}
meterFlipVals = {'ALWAYS','60','120','220','320','420','600','NEVER'}
indentGuideVals = {'HIDE','1','2','3','4','STRONG'}
mcpTitleTrackSize = {30,40,50,60,70,80,90,100}
mcpTitleTrackCol = {'Title','Panel','Neutral'}
mcpStripVolVals = {'MIN','+75','+110','+270','+370'}
mcpStripNameVals = {40,60,80,110,170}
mcpStripExtMixVals = {'HIDE','SHOW'}
mcpFxEmbedVals = {'DEFAULT',100,200,300,400,500,'600 (MAX)'}
mcpFxEmbedMainVals = {'DEFAULT',150,200,300,400,500,'600 (MAX)'}
trackLabelColVals = {'Default','Armed = RED','Folder = BLUE'}
buttonBrightVals = {'MIN',80,90,100,110,120,130,140,'MAX'}
tcpCustomColorVals = {'0 %','20 %','40 %','60 %','80 %'}
mcpCustomButtonVals = {'HIDE ALL','SHOW','SHOW !','MAST. ONLY','ALL (AE)','ALL ! (AE)','MAST. ONLY (AE)'}
tcpFxListColumnVal = {'1 - 1','1 - 2','2 - 3','3 - 4','3 - 5'}

helpL_layout = 'These settings are automatically saved to your REAPER install, and '
             ..'will be used whenever you use this theme.'
helpL_customCol = 'Any assigned custom colors will be saved with your '
             ..'project, when it is saved.'
helpL_colDimming = 'This theme draws custom colors at full strength. Old '
                 ..'projects may appear very bright, dim them here.'
helpL_dock = 'REAPER will remember whether you docked this script, and where.'
helpL_applySize = 'Layout and scale assignments are part of your REAPER '
                ..'project, and will be saved when it is saved.'

helpR_help = 'Customized Theme Adjuster, for all CSIX theme variants.  '
                ..' ________ _ ________  '
                ..'  Values in blue color indicate changes compared to the current theme\'s default settings. '
                ..' ________ _ ________  '
                ..'Double-click to reset single parameters, or run Reset Current to reload the theme with all built-in settings. '
                .. ' N/A means the feature isn\'t available or the parameter was imported from another theme with different options.'
helpR_switchCSIX = 'Switch to another CSIX theme variant.  '
helpR_mergeCSIX = 'Select a CSIX theme variant to open and MERGE with current parameters from the SAVE ALL -settings.   '
                .. ' Tip: Holding ALT will prompt to SAVE ALL before merging.   '
                ..' ________ _ ________  '
                ..' PLEASE NOTE:   '
                ..' Available features and options are different between the CSIX Series.'
helpR_layoutlist = 'Setup default panel Layouts for themes in use. New and not yet formatted tracks will use the settings.     '
                ..'*Note: The default settings also affect other ReaperThemes that have A/B/C formatted layouts, and vice versa. '
helpR_dock = 'Dock this script in its condensed format.'
helpR_trackLabelColor = 'If a track has a custom color, use that color on the track name.'
helpR_resetCurrent = 'This will RESET the current theme back to its default settings.  '
helpR_totalReset = 'REMOVES ALL (!)   user changes for installed CSIX Series. Reloads current theme with default parameter values.  '
                ..'*Renamed Presets will not be removed. '
helpR_csixSetChange = 'Only saves settings that have changed since the theme was loaded. If a preset is imported, these changes will also be included. '
helpR_csixSetImport = 'Loads Theme Adjuster settings from a Preset file. '
helpR_csixSetAll = 'Saves a complete set of All parameters. '
helpR_showPresets = 'Navigates to the CSIX settings folder. If it doesn\'t exist, it will be created. '
helpR_csixsetLoad = 'Loads Saved Changes from the settings file \"csixset\". '
helpR_csixsetLoadAll = 'Loads All params from the settings file \"csixset_all\". '
helpR_colAdj = 'Adjust how REAPER draws the theme colors.  Mousewheel for fine '
              ..'adjustment. Double click the fader to reset. Double click the value to enter a new value.'
helpR_resetColAdj = 'Reset all of these color controls to return the theme to its unaltered state.   '
                ..' If the theme has a hard-coded setting, this will be loaded. '
helpR_buttonBrightness = 'Sets the label brightness on ALL action buttons globally.  '
helpR_custOverlay = 'Adds an extra layer of custom color to all control panels (except on alternate full-tone layouts).  '
helpR_indent = 'Amount to indent a panel due to its depth within the project folder '
             ..'structure.  The value chosen is used by all layouts.'
helpR_control_align = 'Choose whether to indent the panel controls when '
                   ..'folders indent, or to keep controls aligned.  '
                    ..'The value chosen is used by all layouts.'
helpR_showActBtnTcp = 'Allow action buttons to be displayed when the width of the selected panel is wider than the set limit to hide actions. '
                    ..'*The feature is currently setup to work only with CSIX Narrow themes.  '
helpR_indentPinTrack = '*FOR TEST ONLY:  '
                    ..'When ON, Pinned tracks will respect settings for Folder Indentation and Controls Alignment. '
                    ..'Folder Controls are showed only when using Indent mode. '
helpR_showTcpFx = 'Show/Hide Fx Inserts in TCP.'
helpR_showTcpParm = 'Un-checked setting: Reduce noise in TCP by showing active Fx Parameters only if track is selected.'
helpR_showTcpSends = 'Show/Hide Sends below Insert in TCP.  '
                    ..'Optionally engage \'SEP. SENDS\' (Separated Sends List). '
helpR_showActBtnMcp = 'Allow action buttons to be displayed on selected tracks and master mixer panel (when size permits). '
                    ..'Exclamation mark (!) means enhanced appearance with the same setting.  '
helpR_LabelSize = 'Sets the same Name Size for all layouts at once (Except CSIX AE Series where Layout B is fixed).'
helpR_showIndentGuide = 'Displays folder indentation guides with a maximum depth of eight levels.  '
                    ..'*The feature is currently configured for themes in CSIX BC and AE Series.  '
helpR_showActBtnTrans = 'Allow action buttons to be displayed in Transport Bar (when in single row, and when size permits). '
                    ..'TIP: In CSIX AE and BC SERIES, the alternate layout \'TRANSPORT-2\' has even more action buttons, which can be setup in rtconfig (advanced editing).  '
helpR_showMetroBtnTrans = 'Show custom buttons to extend the functionality of the Transport Bar.  '
                    ..'Please note: At this time, custom buttons with a toggle function does NOT indicate on/off state.'
help_playRate = 'If \'Show Play Rate\' is ON, sets the size of the play rate control. '
              ..'TIP : right-click the play rate control to adjust its range.'
helpR_showActVuflip = 'Sets height of the TCP panel when the VU meter will switch to a vertical position.  '
                    ..'*The feature is currently setup only for CSIX Narrow theme.'
helpR_fxparmColumns = 'For CSIX AE Series, layout B) and C):   Sets the number of COLUMNS if the FX LIST on the right side has an overflow.   '
                    ..'TIP: The second number (e.g. 1-2) equals two columns when track is minimized.   '
                    ..'NOTE: This setting is fixed for all other CSIX variants.'
helpR_layoutButton = 'Select layout you wish to edit or apply.'
helpR_default = 'Indicates whether the layout is chosen as the default and can be set from the list at the top ^'
helpR_selected = 'Indicates whether one or more of the selected tracks is using this layout.'
helpR_fallbackA = 'This Theme only has TCP Layout A. If the project contains other formats, they will all fall back to A.'
helpR_applySize = 'Applies this layout to any selected tracks, at this size. '
                ..'REAPER may already be using a non-100% size, depending on your '
                ..'HiDPI settings.'
helpR_nameSizeEnv = 'Size of the envelopes\' name field.  If set to AUTO then, '
                  ..'while the script is running, it will adjust this to fit the '
                  ..'longest envelope name currently in the project.'
helpR_meterScale = 'Requires \'METER EXPANSION\' to be ticked below, and '
                 ..'the conditions you set to be met. Tracks with greater '
                 ..'than 2 channels will then expand the width of their '
                 ..'meters by the set amount of pixels (per channel), and '
                 ..'enlarge the panel width to fit.'
helpR_titleTrack1 = 'Sets width of the alternate TITLE-TRACK layout. *Available only in CSIX BC and AE Series.'
helpR_titleTrack2 = 'Sets appearance of the alternate TITLE-TRACK layout in both MCP and TCP. *Available only in CSIX BC and AE Series.'
helpR_borders = 'Adds visual separation to your mixer with borders. '
              ..'LEFT EDGE and/or RIGHT EDGE allow you to manually use layout '
              ..'assignments to add these as needed. ROOT FOLDERS draws a border on '
              ..'the left edge of root level folders, and on the right hand '
              ..'edge of the end of that folder if it is one level deep. '
              ..'AROUND FOLDERS draws borders at the start and end of every folder.'
helpR_embed = 'When using FX GUI embeddings shown in the mixer panel SIDEBAR, use this setting to EXPAND the panel WIDTH.'
helpR_embedMast = 'If one of the ALTERNATE Master Mixer layouts is chosen, use this setting to EXPAND the panel WIDTH.'
helpR_extmix = 'Only for Slim Channel Strip (CSIX Series). '
                ..'When HIDE is selected, the VU meter fills the available space ABOVE the controls. '
                ..'Selecting SHOW draws the Extended Mixer ABOVE the VU (when dragged down). '
                ..'The Extended Mixer will always be drawn on the left side when SIDEBAR is active. '
helpR_mastermeter = 'If unchecked, meter scales are shown ONLY when master panel is selected.'
helpR_masterw = '* Available only in CSIX AE Series.'
helpR_masterCol = 'AE/BC/MC Series,    Color Master Panel: Hold Shift to choose from swatch Palette, or use the Picker.     '
            ..'  + ALT resets color. '
help_pref = 'These buttons set REAPER preferences. Their settings are automatically '
          ..'saved to your REAPER install.'
help_proj_extmix='These settings are part of your REAPER project, and will be saved '
               ..'when it is saved (except for \'Scroll to selected track\', which is '
               ..'a REAPER preference)'
helpR_recolProject = 'Assigns random colors using the selected palette. Tracks which share '
                   ..'a color will be given the same new color.'
helpR_colgradeChildren = 'Sets a color gradient for all Child tracks, based on selected Folder track color.   '
                   ..'Mouse modifiers: Shift, Ctrl (or both) changes gradient.   '
                    ..'ALT for no gradient.   '
                   ..'*This is a mod based on ICio_Set color gradient to children. Requires SWS/S&M extension.'
helpR_choosePalette = 'Click to select a palette.'
helpR_emvMatchIndent = 'Indent with folders alignment, matching the Folder Indent '
                     ..'Size setting on the Track Panel tab.'

  --------- POPULATE ---------
apply = {}
root = Element:new(nil, {x=0,y=0,drawx=0,drawy=0,w=_gfxw,h=_gfxh,color={46,48,51}}) -- fill

_replaceTheme = Button:new(root, {x=38,y=2,w=362,h=32,action=replaceTheme})
_theme = Element:new(root, {x=0,y=2,w=400,h=32,text={str=''},helpR='Current theme.'})

  ------ DOCKED LAYOUT -------
_dockedRoot = {}
apply.tcp = {}
apply.mcp = {}
apply.envcp = {}
apply.trans = {}

  ----- UNDOCKED LAYOUT ------
_undockedRoot = Element:new(root, {flexW='100%',flexH='100%'})
_pageContainer = Element:new(_undockedRoot, {positionX='center', positionY='center',x=0,y=0,w=513,h=679})

Button:new(_undockedRoot, {x=694,y=2,w=150,h=60,text={str=''..reaper.GetAppVersion(),style=2,align=2,col={136,136,136}},helpR='System info.'})
Button:new(_undockedRoot, {x=694,y=16,w=120,h=15,text={str=''.. OS .. '  –',style=2,align=6,col={136,136,136}}})
Button:new(_undockedRoot, {x=804,y=16,w=40,h=15,img='dpiScale',imgType=3})
_csixVersion = Button:new(_undockedRoot, {x=694,y=32,w=150,h=16,text={str='',style=2,align=2,col={136,136,136}},func=function(self) end}) --csix_version
Element:new(_undockedRoot, {x=694,y=48,w=150,h=16,text={str='CSIX_adjuster 3.5',style=2,align=2,col={136,136,136}}})

_buttonHelp = Button:new(_pageContainer, {flow=false,x=0,y=0,w=50,img='help_on',imgType=3,w=50,action=toggleHelp,helpR=helpR_help})
_pageSpin = Spinner:new(_pageContainer, {spinStyle='image',valsImage='page_titles',x=135,y=0,w=243,action=doPageSpin})
Element:new(_pageContainer, {x=0,y=39,w=513,h=1,color={116,128,149,225}}) -- title div
Button:new(_pageContainer, {x=370,y=-39,w=85,h=30,img='themesettings',imgType=3,action=csixListSwitch,helpR=helpR_switchCSIX})
_csixThemesList = Button:new(_pageContainer, {x=377,y=-37,w=70,h=30,text={str='SWITCH  >',style=3,align=2,col={180,180,181}}})
Button:new(_pageContainer, {x=440,y=-39,w=85,h=30,img='themesettings',imgType=3,action=csixListMerge,helpR=helpR_mergeCSIX})
_csixThemesList = Button:new(_pageContainer, {x=447,y=-37,w=70,h=30,text={str='MERGE  >',style=3,align=2,col={180,180,181}}})
Button:new(_pageContainer, {x=385,y=8,w=140,h=30,img='themesettings',imgType=3,action=csix_layout_list,helpR=helpR_layoutlist})
_csixThemesList = Button:new(_pageContainer, {x=377,y=9,w=140,h=30,text={str='Set default Layout  >',style=3,align=2,col={180,180,181}}})

_subPageContainer = Element:new(_pageContainer, {x=0,y=40,w=513,h=639})

--GLOBAL PAGE
_pageGlobal_und = Element:new(_subPageContainer, {x=0,y=0,w=513,h=639})

_colAdjBoxStroke = Element:new(_pageGlobal_und, {x=0,y=10,w=513,h=529,color={116,128,149,225}}) -- stroke
_colAdjBox = Element:new(_colAdjBoxStroke, {x=1,y=1,w=511,h=527,color={39,41,43},helpL=helpL_layout}) -- fill

Element:new(_colAdjBox, {x=0,y=26,w=511,h=16,text={str='COLOR CONTROLS',style=4,align=5,col={180,180,181}}})
_gamma = Element:new(_colAdjBox, {x=69,y=64,w=373,h=19,color={90,94,94},helpR=helpR_colAdj,interactive=false})
_gammabg =  FaderBg:new(_gamma, {x=1,y=1,w=371,h=17,img='faderbg_gamma',action=doFader,param=-1000,helpR=helpR_colAdj,interactive=false})
Element:new(_gammabg, {x=160,y=2,w=2,h=13,color={0,0,0,104}}) --zero line 255,255,255,64
Fader:new(_gammabg, {x=1,y=-4,action=doFader,param=-1000,helpR=helpR_colAdj})
Element:new(_colAdjBox, {x=69,y=90,w=80,h=11,text={str='GAMMA',style=2,align=4,col={180,180,181}},helpR=helpR_colAdj})
Readout:new(_colAdjBox,{x=145,y=88,w=50,h=15,userEntry=true,action=doFader,moColor={40,40,40},param={-1000},text={str='',align=4,col={180,180,181}},helpR=helpR_colAdj})

_hms = Element:new(_colAdjBox, {x=69,y=118,w=373,h=53,color={90,94,94},helpR=helpR_colAdj,interactive=false})
_highlightbg = FaderBg:new(_hms, {x=1,y=1,w=371,h=17,color={71,73,73},action=doFader,param=-1003,helpR=helpR_colAdj})
Element:new(_highlightbg, {x=186,y=2,w=2,h=13,color={255,255,255,64}}) --zero line
_midtonebg = FaderBg:new(_hms, {x=1,y=18,w=371,h=17,color={57,57,57},action=doFader,param=-1002,helpR=helpR_colAdj})
Element:new(_midtonebg, {x=186,y=2,w=2,h=13,color={255,255,255,64}}) --zero line
_shadowbg = FaderBg:new(_hms, {x=1,y=35,w=371,h=17,color={44,44,44},action=doFader,param=-1001,helpR=helpR_colAdj})
Element:new(_shadowbg, {x=186,y=2,w=2,h=13,color={255,255,255,64}}) --zero line
Fader:new(_highlightbg, {x=1,y=-4,action=doFader,param=-1003,helpR=helpR_colAdj})
Fader:new(_midtonebg, {x=1,y=-4,action=doFader,param=-1002,helpR=helpR_colAdj})
Fader:new(_shadowbg, {x=1,y=-4,action=doFader,param=-1001,helpR=helpR_colAdj})
Element:new(_colAdjBox, {x=69,y=178,w=80,h=11,text={str='HIGHLIGHTS',style=2,align=4,col={180,180,181}},helpR=helpR_colAdj})
Readout:new(_colAdjBox,{x=145,y=176,w=50,h=15,userEntry=true,action=doFader,moColor={40,40,40},param={-1003},text={str='',align=4,col={180,180,181}},helpR=helpR_colAdj})
Element:new(_colAdjBox, {x=190,y=178,w=80,h=11,text={str='MIDTONES',style=2,align=6,col={180,180,181}},helpR=helpR_colAdj})
Readout:new(_colAdjBox,{x=274,y=176,w=50,h=15,userEntry=true,action=doFader,moColor={40,40,40},param={-1002},text={str='',align=4,col={180,180,181}},helpR=helpR_colAdj})
Element:new(_colAdjBox, {x=320,y=178,w=80,h=11,text={str='SHADOWS',style=2,align=6,col={180,180,181}},helpR=helpR_colAdj})
Readout:new(_colAdjBox,{x=408,y=176,w=46,h=15,userEntry=true,action=doFader,moColor={40,40,40},param={-1001},text={str='',align=4,col={180,180,181}},helpR=helpR_colAdj})

_saturation = Element:new(_colAdjBox, {x=69,y=208,w=373,h=19,color={90,94,94},helpR=helpR_colAdj,interactive=false})
_saturationbg = FaderBg:new(_saturation, {x=1,y=1,w=371,h=17,img='faderbg_saturation',action=doFader,param=-1004,helpR=helpR_colAdj})
Element:new(_saturationbg, {x=186,y=2,w=2,h=13,color={255,255,255,64}}) --zero line
Fader:new(_saturationbg, {x=1,y=-4,action=doFader,param=-1004,helpR=helpR_colAdj})
Element:new(_colAdjBox, {x=69,y=234,w=80,h=11,text={str='SATURATION',style=2,align=4,col={180,180,181}},helpR=helpR_colAdj})
Readout:new(_colAdjBox,{x=145,y=232,w=50,h=15,userEntry=true,action=doFader,moColor={40,40,40},param={-1004},text={str='',align=4,col={180,180,181}},helpR=helpR_colAdj})

_tint = Element:new(_colAdjBox, {x=69,y=264,w=373,h=19,color={90,94,94},helpR=helpR_colAdj,interactive=false})
_tintbg = FaderBg:new(_tint, {x=1,y=1,w=371,h=17,img='faderbg_tint',action=doFader,param=-1005,helpR=helpR_colAdj})
Element:new(_tintbg, {x=186,y=2,w=2,h=13,color={255,255,255,64}}) --zero line
Fader:new(_tintbg, {x=1,y=-4,action=doFader,param=-1005,helpR=helpR_colAdj})
Element:new(_colAdjBox, {x=69,y=290,w=80,h=11,text={str='TINT',style=2,align=4,col={180,180,181}},helpR=helpR_colAdj})
Readout:new(_colAdjBox,{x=145,y=288,w=50,h=15,userEntry=true,action=doFader,moColor={40,40,40},param={-1005},text={str='',align=4,col={180,180,181}},helpR=helpR_colAdj})

Button:new(_colAdjBox, {x=64,y=316,w=30,img='color_apply_all',imgType=3,action=paramToggle,param=-1006})
Element:new(_colAdjBox, {x=96,y=316,w=190,h=30,text={str='Also affect project Custom Colors',style=2,align=4,col={180,180,181}}})
Button:new(_colAdjBox, {x=288,y=316,w=30,img='bin',imgType=3,action=resetColorControls,helpR=helpR_resetColAdj})
Element:new(_colAdjBox, {x=317,y=316,w=160,h=30,text={str='Reset / Read Color Controls',style=2,align=4,col={180,180,181}},helpR=helpR_resetColAdj})

Element:new(_colAdjBox, {x=30,y=356,w=450,h=1,color={116,128,149,225}}) -- title div
Element:new(_colAdjBox, {x=0,y=368,w=511,h=20,text={str='Additional settings for AE and BC Series:',style=3,align=5,col={136,136,136}}})

Element:new(_colAdjBox, {x=30,y=400,w=138,h=16,text={str='TRACK NAMES',style=2,align=5,col={180,180,181}}})
Element:new(_colAdjBox, {x=30,y=418,w=138,h=16,text={str='Indicates Properties',style=2,align=5,col={160,160,161}}})
Spinner:new(_colAdjBox, {x=30,y=440,w=138,title='SHOW',action=paramSet,param='glb_trackLabelCol',valsTable=trackLabelColVals})

Element:new(_colAdjBox, {x=186,y=400,w=138,h=16,text={str='ACTION BUTTONS',style=2,align=5,col={180,180,181}}})
Element:new(_colAdjBox, {x=186,y=418,w=138,h=16,text={str='* Label Brightness',style=2,align=5,col={160,160,161}}})
Spinner:new(_colAdjBox, {x=186,y=440,w=138,title='BRIGHT.',action=paramSet,param='ctrl_Param_201',valsTable=buttonBrightVals})

Element:new(_colAdjBox, {x=342,y=400,w=138,h=16,text={str='TCP/MCP TINT',style=2,align=5,col={180,180,181}}})
Element:new(_colAdjBox, {x=342,y=418,w=138,h=16,text={str='* Custom Color',style=2,align=5,col={160,160,161}}})
Spinner:new(_colAdjBox, {x=342,y=440,w=138,title='OPACITY',action=paramSet,param='glb_customOverlay',valsTable=tcpCustomColorVals})

Element:new(_colAdjBox, {x=30,y=400,w=138,h=70,helpL=helpL_layout}) -- helpL
Element:new(_colAdjBox, {x=186,y=400,w=138,h=70,helpL=helpL_layout,helpR=helpR_buttonBrightness}) -- helpL, helpR
Element:new(_colAdjBox, {x=342,y=400,w=138,h=70,helpL=helpL_layout,helpR=helpR_custOverlay}) -- helpL, helpR

Element:new(_colAdjBox, {x=30,y=490,w=450,h=1,color={116,128,149,225}}) -- title div

Button:new(_colAdjBox, {x=0,y=496,w=170,h=24,img='themesettings',imgType=3,action=resetCurrent,helpR=helpR_resetCurrent})
Element:new(_colAdjBox, {x=0,y=498,w=170,h=16,text={str='Reset Current Theme',style=2,align=5,col={210,106,106}}})
Button:new(_colAdjBox, {x=340,y=496,w=170,h=24,img='themesettings',imgType=3,action=totalReset,helpR=helpR_totalReset})
Element:new(_colAdjBox, {x=340,y=498,w=170,h=16,text={str='Total Reset CSIX',style=2,align=5,col={210,106,106}}})

-- CSIX settings
Button:new(_pageGlobal_und, {x=0,y=546,w=170,h=24,img='themesettings',imgType=3,action=exportParams,helpR=helpR_csixSetChange})
Element:new(_pageGlobal_und, {x=0,y=548,w=170,h=16,text={str='SAVE CHANGES',style=2,align=5,col={180,180,181}}})
Button:new(_pageGlobal_und, {x=170,y=546,w=170,h=24,img='themesettings',imgType=3,action=importParams,helpR=helpR_csixSetImport})
Element:new(_pageGlobal_und, {x=170,y=548,w=170,h=16,text={str='IMPORT SETTINGS *',style=2,align=5,col={180,180,181}}})
Button:new(_pageGlobal_und, {x=170,y=(546+26),w=170,h=24,img='themesettings',imgType=3,action=showSettingPath,helpR=helpR_showPresets})
Element:new(_pageGlobal_und, {x=170,y=(548+26),w=170,h=16,text={str='Show Presets',style=2,align=5,col={180,180,181}}})
Button:new(_pageGlobal_und, {x=340,y=546,w=170,h=24,img='themesettings',imgType=3,action=exportParamsAll,helpR=helpR_csixSetAll})
Element:new(_pageGlobal_und, {x=340,y=548,w=170,h=16,text={str='SAVE ALL SETTINGS',style=2,align=5,col={180,180,181}}})
Button:new(_pageGlobal_und, {x=0,y=572,w=170,h=24,img='themesettings',imgType=3,action=importCsixSet,helpR=helpR_csixsetLoad})
Element:new(_pageGlobal_und, {x=0,y=574,w=170,h=16,text={str='Load Changes',style=2,align=5,col={180,180,181}}})
Button:new(_pageGlobal_und, {x=340,y=572,w=170,h=24,img='themesettings',imgType=3,action=importCsixSetAll,helpR=helpR_csixsetLoadAll})
Element:new(_pageGlobal_und, {x=340,y=574,w=170,h=16,text={str='Load All',style=2,align=5,col={180,180,181}}})

Button:new(_pageGlobal_und, {x=150,y=609,w=205,h=40,img='themelogo',imgType=3,action=open_url_csix}) -- CSIX webpage

--TRACK PAGE
_pageTrack_und = Element:new(_subPageContainer, {x=0,y=0,w=513,h=639})
_tcpBtnOlHelp = Element:new(_pageTrack_und, {x=92,y=60,w=154,h=86,visible=false,helpR=helpR_fallbackA}) --basic narrow tcp A only helptxt

Spinner:new(_pageTrack_und, {x=10,y=6,w=155,title='FOLDER INDENT',action=paramSet,param='tcp_indent',valsTable=folderIndentVals,helpR=helpR_indent,helpL=helpL_layout})
Spinner:new(_pageTrack_und, {x=180,y=6,w=155,title='ALIGN CONTROLS',action=paramSet,param='tcp_control_align',valsTable=controlAlignVals,helpR=helpR_control_align,helpL=helpL_layout})
Spinner:new(_pageTrack_und, {x=348,y=6,w=155,title='HIDE ACTIONS *',action=paramSet,param='tcp_customButton',valsTable=tcpCustomButtonVals,helpL=helpL_layout,helpR=helpR_showActBtnTcp})

Button:new(_pageTrack_und, {x=33,y=29,w=30,img='check-buttons_check_gray',imgType=3,action=paramToggle,param='ctrl_Param_301',helpR=helpR_indentPinTrack,helpL=helpL_layout})
Element:new(_pageTrack_und, {x=56,y=30,w=125,h=30,text={str='Indent Pinned *',style=2,align=4,col={180,180,181}},helpR=helpR_indentPinTrack,helpL=helpL_layout})
Button:new(_pageTrack_und, {x=261,y=39,w=30,img='check-buttons_check_gray',imgType=3,action=actionToggle,param=40302,helpR=helpR_showTcpFx,helpL=help_pref})
Element:new(_pageTrack_und, {x=284,y=40,w=25,h=30,text={str='FX',style=2,align=4,col={180,180,181}},helpR=helpR_showTcpFx,helpL=help_pref})
Button:new(_pageTrack_und, {x=303,y=39,w=30,img='check-buttons_check_gray',imgType=3,action=paramToggle,param='tcp_fxParmVis',helpR=helpR_showTcpParm,helpL=helpL_layout})
Element:new(_pageTrack_und, {x=326,y=40,w=125,h=30,text={str='FX PARM (ALWAYS) *',style=2,align=4,col={180,180,181}},helpR=helpR_showTcpParm,helpL=helpL_layout})
Button:new(_pageTrack_und, {x=442,y=39,w=30,img='check-buttons_check_gray',imgType=3,action=actionToggle,param=40677,helpR=helpR_showTcpSends,helpL=help_pref})
Element:new(_pageTrack_und, {x=465,y=40,w=50,h=30,text={str='SENDS',style=2,align=4,col={180,180,181}},helpR=helpR_showTcpSends,helpL=help_pref})

_layoutTrackStroke = Element:new(_pageTrack_und, {x=0,y=153,w=513,h=496,color={116,128,149,225}}) -- stroke

_tcpButLayA = Button:new(_pageTrack_und, {x=20,y=65,w=69,h=50,img='layout_select_A',imgType=3,action=doActiveLayout,param={'tcp','A'},helpR=helpR_layoutButton})
_tcpButLayB = Button:new(_pageTrack_und, {x=93,y=65,w=69,h=50,img='layout_select_B',imgType=3,action=doActiveLayout,param={'tcp','B'},helpR=helpR_layoutButton})
_tcpButLayC = Button:new(_pageTrack_und, {x=166,y=65,w=69,h=50,img='layout_select_C',imgType=3,action=doActiveLayout,param={'tcp','C'},helpR=helpR_layoutButton})
Readout:new(_tcpButLayA, {x=5,y=50,w=64,h=12,text={str='Default',style=1,align=5,colFalse={254,254,254,30},colTrue={179,197,229}},updateState=isDefault,getParam={'tcp','A'},helpR=helpR_default})
Readout:new(_tcpButLayB, {x=5,y=50,w=64,h=12,text={str='Default',style=1,align=5,colFalse={254,254,254,30},colTrue={179,197,229}},updateState=isDefault,getParam={'tcp','B'},helpR=helpR_default})
Readout:new(_tcpButLayC, {x=5,y=50,w=64,h=12,text={str='Default',style=1,align=5,colFalse={254,254,254,30},colTrue={179,197,229}},updateState=isDefault,getParam={'tcp','C'},helpR=helpR_default})
Readout:new(_tcpButLayA, {x=5,y=65,w=64,h=12,text={str='SELECTED',style=1,align=5,colFalse={254,254,254,30},colTrue={230,115,115}},updateState=anySelected,getParam={'tcp','A'},helpR=helpR_selected})
Readout:new(_tcpButLayB, {x=5,y=65,w=64,h=12,text={str='SELECTED',style=1,align=5,colFalse={254,254,254,30},colTrue={230,115,115}},updateState=anySelected,getParam={'tcp','B'},helpR=helpR_selected})
Readout:new(_tcpButLayC, {x=5,y=65,w=64,h=12,text={str='SELECTED',style=1,align=5,colFalse={254,254,254,30},colTrue={230,115,115}},updateState=anySelected,getParam={'tcp','C'},helpR=helpR_selected})

_tcpTrackSound_A = Button:new(_pageTrack_und, {x=37, y=86, w=39, img='tracksound', imgType=3, action=doTrackSound, param={'tcp','A'}, signalState=0}) --tcp trackSound
_tcpTrackSound_B = Button:new(_pageTrack_und, {x=110, y=86, w=39, img='tracksound', imgType=3, action=doTrackSound, param={'tcp','B'}, signalState=0})
_tcpTrackSound_C = Button:new(_pageTrack_und, {x=183, y=86, w=39, img='tracksound', imgType=3, action=doTrackSound, param={'tcp','C'}, signalState=0})

_tcpBtnOverlay = Element:new(_pageTrack_und, {x=92,y=60,w=154,h=86,color={46,48,51,170},visible=false,helpR=helpR_fallbackA}) --basic narrow tcp A only

_applyStroke_Track = Element:new(_pageTrack_und, {x=254,y=70,w=259,h=83,color={116,128,149,225}}) -- stroke
_applyBox_Track = Element:new(_applyStroke_Track, {x=1,y=1,w=257,h=83,color={46,48,51},helpL=helpL_applySize}) -- fill
Element:new(_applyStroke_Track, {x=17,y=16,w=213,h=67,color={0,0,0,35},helpL=helpL_applySize}) -- fill
apply.und = {tcp={Button:new(_applyBox_Track, {x=60,y=25,w=61,img='apply_100',imgType=3,action=applyLayout,param={'tcp',''},helpR=helpR_applySize,helpL=helpL_applySize})}}
apply.und.tcp[2] = Button:new(_applyBox_Track, {x=90,y=25,w=61,img='apply_150',imgType=3,action=applyLayout,param={'tcp','150%_'},helpR=helpR_applySize,helpL=helpL_applySize,visible=false}) -- NA
apply.und.tcp[3] = Button:new(_applyBox_Track, {x=123,y=25,w=61,img='apply_200',imgType=3,action=applyLayout,param={'tcp','200%_'},helpR=helpR_applySize,helpL=helpL_applySize})
Element:new(_applyBox_Track, {x=21,y=60,w=200,h=10,img='apply_to_sel'})

_layoutTrack = Element:new(_layoutTrackStroke, {x=1,y=1,w=511,h=494,color={46,48,51},helpL=helpL_layout}) -- fill
_tcpPageOverlay = Element:new(_layoutTrack, {x=0,y=0,w=511,h=494,color={200,100,100,20},visible=false,helpR=helpR_fallbackA}) --basic narrow tcp A only

Spinner:new(_layoutTrack, {x=30,y=9,w=129,title='NAME SIZE *',action=paramSet,param='tcp_LabelSize',valsTable=tcpLabelVals,helpL=helpL_layout,helpR=helpR_LabelSize}) -- global
Spinner:new(_layoutTrack, {x=30,y=45,w=129,title='VOLUME SIZE',action=paramSet,param='tcp_vol_size',valsTable=tcpVolVals})
Spinner:new(_layoutTrack, {x=30,y=82,w=129,title='GUIDES *',action=paramSet,param='tcp_indentGuide',valsTable=indentGuideVals,helpL=helpL_layout,helpR=helpR_showIndentGuide})
Spinner:new(_layoutTrack, {x=190,y=9,w=129,title='INPUT SIZE',action=paramSet,param='tcp_InputSize',valsTable=tcpInVals})
Spinner:new(_layoutTrack, {x=190,y=45,w=129,title='METER SIZE',action=paramSet,param='tcp_MeterSize',valsTable=tcpMeterVals})
Spinner:new(_layoutTrack, {x=190,y=82,w=129,title='not used'})
--- tcpMeterLocVals = {'LEFT','RIGHT','LEFT IF ARMED'} -- NA
--- Spinner:new(_layoutTrack, {x=273,y=70,w=159,title='METER LOCATION',action=paramSet,param='tcp_MeterLoc',valsTable=tcpMeterLocVals}) -- NA
Spinner:new(_layoutTrack, {x=353,y=9,w=129,title='SEP. SENDS',action=paramSet,param='tcp_sepSends',valsTable=seperateSendsVals,helpL=helpL_layout})
Spinner:new(_layoutTrack, {x=353,y=45,w=129,title='METER FLIP *',action=paramSet,param='tcp_meterFlip',valsTable=meterFlipVals,helpR=helpR_showActVuflip,helpL=helpL_layout})
Spinner:new(_layoutTrack, {x=353,y=82,w=129,title='FX-LIST *',action=paramSet,param='tcp_fxparm_column',valsTable=tcpFxListColumnVal,helpR=helpR_fxparmColumns,helpL=helpL_layout})

tcpTableVals = {img = 'cell_hide',
                columns = {{visFlag=1,text={str='If Mixer#is Visible'}},{visFlag=2,text={str='If Track#not Selected'}},
                        {visFlag=4,text={str='If Track#not Armed'}},{visFlag=8,text={str='ALWAYS#HIDE'}}},
                rows = {{param='tcp_Record_Arm',text={str='Record Arm '}},
                        {param='tcp_Monitor',text={str='Monitor'}},
                        {param='tcp_Track_Name',text={str='Track Name'}},
                        {param='tcp_Volume',text={str='Volume'}},
                        {param='tcp_Routing',text={str='Routing'}},
                        {param='tcp_Effects',text={str='Insert FX'}},
                        {param='tcp_Envelope',text={str='Envelope'}},
                        {param='tcp_Pan_&_Width',text={str='Pan & Width'}},
                        {param='tcp_Record_Mode',text={str='Record Mode'}},
                        {param='tcp_Input',text={str='Input'}},
                        {param='tcp_Phase',text={str='Polarity Switch'}},
                        {param='tcp_Values',text={str='Labels & Values'}},
                        {param='tcp_Meter_Values',text={str='Meter Values'}}}
}
_trackTable = ParamTable:new(_layoutTrack, {x=29,y=123,w=453,h=355,valsTable=tcpTableVals})

--MIXER PAGE
_pageMixer_und = Element:new(_subPageContainer, {x=0,y=0,w=513,h=639})
Spinner:new(_pageMixer_und, {x=10,y=6,w=155,title='FOLDER INDENT',action=paramSet,param='mcp_indent',valsTable=folderIndentVals,helpR=helpR_indent,helpL=helpL_layout})
Spinner:new(_pageMixer_und, {x=180,y=6,w=155,title='ALIGN CONTROLS',action=paramSet,param='mcp_control_align',valsTable=controlAlignVals,helpR=helpR_control_align,helpL=helpL_layout})
Spinner:new(_pageMixer_und, {x=348,y=6,w=155,title='MCP ACTIONS *',action=paramSet,param='mcp_customButton',valsTable=mcpCustomButtonVals,helpL=helpL_layout,helpR=helpR_showActBtnMcp})

_mixerTopStroke = Element:new(_pageMixer_und, {x=0,y=133,w=513,h=330,color={116,128,149,225}}) -- stroke

_mcpButLayA = Button:new(_pageMixer_und, {x=30,y=45,w=69,h=50,img='layout_select_A_blue',imgType=3,action=doActiveLayout,param={'mcp','A'},helpR=helpR_layoutButton})
_mcpButLayB = Button:new(_pageMixer_und, {x=103,y=45,w=69,h=50,img='layout_select_B_blue',imgType=3,action=doActiveLayout,param={'mcp','B'},helpR=helpR_layoutButton})
_mcpButLayC = Button:new(_pageMixer_und, {x=176,y=45,w=69,h=50,img='layout_select_C_blue',imgType=3,action=doActiveLayout,param={'mcp','C'},helpR=helpR_layoutButton})
Readout:new(_mcpButLayA, {x=5,y=50,w=64,h=12,text={str='Default',style=1,align=5,colFalse={254,254,254,30},colTrue={179,197,229}},updateState=isDefault,getParam={'mcp','A'},helpR=helpR_default})
Readout:new(_mcpButLayB, {x=5,y=50,w=64,h=12,text={str='Default',style=1,align=5,colFalse={254,254,254,30},colTrue={179,197,229}},updateState=isDefault,getParam={'mcp','B'},helpR=helpR_default})
Readout:new(_mcpButLayC, {x=5,y=50,w=64,h=12,text={str='Default',style=1,align=5,colFalse={254,254,254,30},colTrue={179,197,229}},updateState=isDefault,getParam={'mcp','C'},helpR=helpR_default})
Readout:new(_mcpButLayA, {x=5,y=65,w=64,h=12,text={str='SELECTED',style=1,align=5,colFalse={254,254,254,30},colTrue={230,115,115}},updateState=anySelected,getParam={'mcp','A'},helpR=helpR_selected})
Readout:new(_mcpButLayB, {x=5,y=65,w=64,h=12,text={str='SELECTED',style=1,align=5,colFalse={254,254,254,30},colTrue={230,115,115}},updateState=anySelected,getParam={'mcp','B'},helpR=helpR_selected})
Readout:new(_mcpButLayC, {x=5,y=65,w=64,h=12,text={str='SELECTED',style=1,align=5,colFalse={254,254,254,30},colTrue={230,115,115}},updateState=anySelected,getParam={'mcp','C'},helpR=helpR_selected})

_mcpTrackSound_A = Button:new(_pageMixer_und, {x=47, y=66, w=39, img='tracksound', imgType=3, action=doTrackSound, param={'mcp','A'}, signalState=0}) --mcp TrackSound
_mcpTrackSound_B = Button:new(_pageMixer_und, {x=120, y=66, w=39, img='tracksound', imgType=3, action=doTrackSound, param={'mcp','B'}, signalState=0})
_mcpTrackSound_C = Button:new(_pageMixer_und, {x=193, y=66, w=39, img='tracksound', imgType=3, action=doTrackSound, param={'mcp','C'}, signalState=0})
_trackSound = {_tcpTrackSound_A, _tcpTrackSound_B, _tcpTrackSound_C, _mcpTrackSound_A, _mcpTrackSound_B, _mcpTrackSound_C} --tcp and mcp

_applyStroke_Mixer = Element:new(_pageMixer_und, {x=274,y=50,w=239,h=83,color={116,128,149,225},helpL=helpL_applySize}) -- stroke
_applyBox_Mixer = Element:new(_applyStroke_Mixer, {x=1,y=1,w=237,h=83,color={46,48,51},helpL=helpL_applySize}) -- fill
Element:new(_applyStroke_Mixer, {x=17,y=16,w=205,h=67,color={0,0,0,35},helpL=helpL_applySize}) -- fill
apply.und.mcp = {Button:new(_applyBox_Mixer, {x=54,y=25,w=61,img='apply_100',imgType=3,action=applyLayout,param={'mcp',''},helpR=helpR_applySize,helpL=helpL_applySize})}
apply.und.mcp[2] = Button:new(_applyBox_Mixer, {x=90,y=25,w=61,img='apply_150',imgType=3,action=applyLayout,param={'mcp','150%_'},helpR=helpR_applySize,helpL=helpL_applySize,visible=false}) -- NA
apply.und.mcp[3] = Button:new(_applyBox_Mixer, {x=115,y=25,w=61,img='apply_200',imgType=3,action=applyLayout,param={'mcp','200%_'},helpR=helpR_applySize,helpL=helpL_applySize})
Element:new(_applyBox_Mixer, {x=17,y=60,w=200,h=10,img='apply_to_sel'})

_mixerTop = Element:new(_mixerTopStroke, {x=1,y=1,w=511,h=328,color={46,48,51},helpL=helpL_layout}) -- fill
Spinner:new(_mixerTop, {x=10,y=10,w=185,title='ADD MCP BORDER',action=paramSet,param='mcp_border',valsTable=mcpBorderVals,helpL=helpL_layout,helpR=helpR_borders})
Spinner:new(_mixerTop, {x=10,y=48,w=185,title='FX EMBED (SIDEBAR)',action=paramSet,param='mcp_fxEmbedSize',valsTable=mcpFxEmbedVals,helpL=helpL_layout,helpR=helpR_embed})
Spinner:new(_mixerTop, {x=10,y=86,w=185,title='FX EMBED (ALT. MAST)',action=paramSet,param='mcp_fxEmbedSizeMain',valsTable=mcpFxEmbedMainVals,helpL=helpL_layout,helpR=helpR_embedMast})
Spinner:new(_mixerTop, {x=208,y=10,w=140,title='METER EXP.',action=paramSet,param='mcp_meterExpSize',valsTable=dockedMcpMeterExpVals,helpL=helpL_layout,helpR=helpR_meterScale})
Spinner:new(_mixerTop, {x=208,y=48,w=140,title='Title-Track Size*',action=paramSet,param='glb_TitleTrackSize',valsTable=mcpTitleTrackSize,helpR=helpR_titleTrack1})
Spinner:new(_mixerTop, {x=208,y=86,w=140,title='Title-Track Col.*',action=paramSet,param='glb_TitleTrackCol',valsTable=mcpTitleTrackCol,helpR=helpR_titleTrack2})
Spinner:new(_mixerTop, {x=360,y=10,w=140,title='VOL SIZE (C)',action=paramSet,param='mcp_StripVolumeSize',valsTable=mcpStripVolVals})
Spinner:new(_mixerTop, {x=360,y=48,w=140,title='NAME SIZE (C)',action=paramSet,param='mcp_StripNameSize',valsTable=mcpStripNameVals})
Spinner:new(_mixerTop, {x=360,y=86,w=140,title='EXT.MIXER (C)*',action=paramSet,param='mcp_StripExtMix',valsTable=mcpStripExtMixVals,helpL=helpL_layout,helpR=helpR_extmix})

mcpTableVals = {img = 'cell_tick_blue',
                columns = {{visFlag=1,text={str='If Selected'}},{visFlag=2,text={str='Not Selected'}},
                        {visFlag=4,text={str='If Armed'}},{visFlag=8,text={str='Not Armed'}}},
                rows = {{param='mcp_Sidebar',text={str='Extend with Sidebar', helpR=helpR_sidebar}},
                        {param='mcp_Narrow',text={str='Narrow Form (A) (B)'}},
                        {param='mcp_Meter_Expansion',text={str='Meter Exp. (A) (B)'}},
                        {param='mcp_InputSec',text={str='Input Section (A) (B)'}},
                        {param='mcp_envSec',text={str='Auto.Mode (A) (B)'}},
                        {param='mcp_RecSec',text={str='REC Section'}},
                        {param='mcp_Labels',text={str='Element Labels'}}}
}
_mixerTable = ParamTable:new(_mixerTop, {x=29,y=120,w=453,h=205,valsTable=mcpTableVals})

_mMid = Element:new(_pageMixer_und, {x=0,y=468,w=513,h=31,color={116,128,149,225}}) -- stroke
_genMixer = Element:new(_mMid, {x=1,y=1,w=511,h=29,color={39,41,43},helpL=help_pref}) -- fill
Button:new(_genMixer, {x=23,y=0,w=30,img='check-buttons_check',imgType=3,action=actionToggle,param=40371})
Element:new(_genMixer, {x=50,y=1,w=160,h=30,text={str='Show Multiple-Row in Mixer',style=2,align=4,col={180,180,181}}})
Button:new(_genMixer, {x=213,y=0,w=30,img='check-buttons_check',imgType=3,action=actionToggle,param=40221}) 
Element:new(_genMixer, {x=240,y=1,w=140,h=30,text={str='Scroll to Selected Track',style=2,align=4,col={180,180,181}}})
Button:new(_genMixer, {x=389,y=0,w=30,img='check-buttons_check',imgType=3,action=actionToggle,param=40903})
Element:new(_genMixer, {x=416,y=1,w=80,h=30,text={str='Show Icons',style=2,align=4,col={180,180,181}}})

_mLower = Element:new(_pageMixer_und, {x=0,y=504,w=513,h=145,color={116,128,149,225}}) -- stroke
_extMixerf = Element:new(_mLower, {x=1,y=1,w=255,h=143,color={39,41,43},helpL=help_pref}) -- fill
Element:new(_extMixerf, {x=29,y=8,w=257,h=20,text={str='EXTENDED MIXER :',style=2,align=0,col={180,180,181}}})
Button:new(_extMixerf, {x=23,y=21,w=30,img='check-buttons_check_blue',imgType=3,action=actionToggle,param=40549}) 
Element:new(_extMixerf, {x=50,y=21,w=190,h=30,text={str='Show FX Inserts',style=2,align=4,col={180,180,181}}})
Button:new(_extMixerf, {x=23,y=50,w=30,img='check-buttons_check_blue',imgType=3,action=actionToggle,param=40910})
Element:new(_extMixerf, {x=50,y=50,w=190,h=30,text={str='Show FX Parameters',style=2,align=4,col={180,180,181}}})
Button:new(_extMixerf, {x=48,y=67,w=30,img='check-buttons_check_blue',imgType=3,action=actionToggle,param=41829})
Element:new(_extMixerf, {x=74,y=67,w=190,h=30,text={str='Group with their Inserts',style=2,align=4,col={180,180,181}}})
Button:new(_extMixerf, {x=23,y=94,w=30,img='check-buttons_check_blue',imgType=3,action=actionToggle,param=40557})
Element:new(_extMixerf, {x=50,y=94,w=190,h=30,text={str='Show Sends',style=2,align=4,col={180,180,181}}})
Button:new(_extMixerf, {x=48,y=111,w=30,img='check-buttons_check_blue',imgType=3,action=actionToggle,param=40267})
Element:new(_extMixerf, {x=74,y=111,w=190,h=30,text={str='Group below/after Inserts',style=2,align=4,col={180,180,181}}})

_mastMixer = Element:new(_mLower, {x=256,y=1,w=256,h=143,color={46,48,51}}) -- fill
Element:new(_mastMixer, {x=22,y=8,w=257,h=20,text={str='MASTER MIXER :',style=2,align=0,col={180,180,181}}})

Button:new(_mastMixer, {x=16,y=21,w=30,img='check-buttons_check_blue',imgType=3,action=actionToggle,param=40389,helpL=help_pref})
Element:new(_mastMixer, {x=45,y=21,w=190,h=30,text={str='Show Master on Right Side',style=2,align=4,col={180,180,181}},helpL=help_pref})
Button:new(_mastMixer, {x=16,y=45,w=30,img='check-buttons_check_blue',imgType=3,action=actionToggle,param=41610,helpL=help_pref})
Element:new(_mastMixer, {x=45,y=45,w=190,h=30,text={str='Toggle in Dock',style=2,align=4,col={180,180,181}},helpL=help_pref})
Button:new(_mastMixer, {x=16,y=67,w=30,img='check-buttons_check_blue',imgType=3,action=actionToggle,param=41636,helpL=help_pref})
Element:new(_mastMixer, {x=45,y=67,w=190,h=30,text={str='Toggle in Floating Window',style=2,align=4,col={180,180,181}},helpL=help_pref})
Button:new(_mastMixer, {x=16,y=89,w=30,img='check-buttons_check_blue',imgType=3,action=paramToggle,param='glb_simpleMaster',helpR=helpR_mastermeter})
Element:new(_mastMixer, {x=45,y=89,w=190,h=30,text={str='Always Show Meter Scales *',style=2,align=4,col={180,180,181}},helpR=helpR_mastermeter})
Button:new(_mastMixer, {x=16,y=111,w=30,img='check-buttons_check_blue',imgType=3,action=paramToggle,param='glb_wideMaster',helpR=helpR_masterw})
Element:new(_mastMixer, {x=45,y=111,w=190,h=30,text={str='Wide Meter (for AE Master W) *',style=2,align=4,col={180,180,181}},helpR=helpR_masterw})


--COLOR PAGE
_pageColor_und = Element:new(_subPageContainer, {x=0,y=30,w=513,h=649})
_paletteBoxStroke = Element:new(_pageColor_und, {x=0,y=0,w=513,h=495,color={116,128,149,225}}) -- stroke
_paletteBox = Element:new(_paletteBoxStroke, {x=1,y=1,w=511,h=225,color={46,48,51},helpL=helpL_customCol}) -- fill

_masterBox = Element:new(_paletteBox, {x=400,y=142,w=111,h=60,helpR=helpR_masterCol}) --color master help
Element:new(_masterBox, {x=30,y=9,w=6,h=6,draw=drawMasterColorSwatch}) --color master
Button:new(_masterBox, {x=26,y=6,w=30,h=30,img='color_picker_main',imgType=3,action=MasterCustomColor}) --color master apply
Element:new(_masterBox, {x=0,y=40,w=84,h=20,text={str='Color Master *',style=2,align=9,col={180,180,181}}})

Readout:new(_paletteBox, {x=124,y=9,w=263,h=30,param={'scriptVariable',palette.current},text={str='LUNA',style=4,align=5,col={180,180,181}},valsTable=undockPaletteNamesVals})

Element:new(_paletteBox, {x=30,y=29,w=450,h=0,color={0,0,0}}) --div above
_palette = Palette:new(_paletteBox, {x=30,y=48,w=450,h=45,cellW=45,img='color_apply',action=applyCustCol})
Element:new(_paletteBox, {x=30,y=101,w=450,h=1,color={254,254,254,60}}) --div below
Element:new(_paletteBox, {x=30,y=110,w=450,h=20,text={str='Apply to all Selected Tracks.   Hold Ctrl (Cmd) for Items only.   Hold Shift for Master.',style=2,align=1,col={180,180,181}}})
--- Set project colors
Button:new(_paletteBox, {x=27,y=140,w=30,img='color_apply_all',imgType=3,action=applyPalette,helpR=helpR_recolProject})
Element:new(_paletteBox, {x=62,y=140,w=170,h=30,text={str='Project: Recolor using Palette *',style=2,align=4,col={180,180,181}},helpR=helpR_recolProject})
--- Set gradient to children
Button:new(_paletteBox, {x=27,y=180,w=30,img='color_children',imgType=3,action=applyChildren,helpR=helpR_colgradeChildren})
Element:new(_paletteBox, {x=62,y=180,w=170,h=30,text={str='Color Gradient to Children *',style=2,align=4,col={180,180,181}},helpR=helpR_colgradeChildren})
--- Set items to default color
Button:new(_paletteBox, {x=241,y=140,w=30,img='bin',imgType=3,action=setItemsDefaultColor,helpR=helpR_recolProjec})
Element:new(_paletteBox, {x=272,y=140,w=130,h=30,text={str='Items: Set to Default',style=2,align=4,col={180,180,181}}})
--- Set takes to default color
Button:new(_paletteBox, {x=241,y=180,w=30,img='bin',imgType=3,action=setTakesDefaultColor,helpR=helpR_recolProjec})
Element:new(_paletteBox, {x=272,y=180,w=130,h=30,text={str='Takes: Set to Default',style=2,align=4,col={180,180,181}}})

_paletteMenuBox = Element:new(_paletteBoxStroke, {x=1,y=222,w=511,h=272,color={39,41,43}}) -- fill

-- add swatches
Swatch:new(_paletteMenuBox,{x=29,y=22,paletteIdx=1})
Swatch:new(_paletteMenuBox,{x=29,y=70,paletteIdx=3})
Swatch:new(_paletteMenuBox,{x=29,y=118,paletteIdx=5})
Swatch:new(_paletteMenuBox,{x=282,y=22,paletteIdx=2})
Swatch:new(_paletteMenuBox,{x=282,y=70,paletteIdx=4})
Swatch:new(_paletteMenuBox,{x=282,y=118,paletteIdx=6})
---
Swatch:new(_paletteMenuBox,{x=29,y=166,paletteIdx=7})
Swatch:new(_paletteMenuBox,{x=29,y=214,paletteIdx=9})
Swatch:new(_paletteMenuBox,{x=282,y=166,paletteIdx=8})
Swatch:new(_paletteMenuBox,{x=282,y=214,paletteIdx=10})

Button:new(_pageColor_und, {x=28,y=507,img='color_dim_all',imgType=3,action=reduceCustCol,param=false})
Element:new(_pageColor_und, {x=63,y=507,w=210,h=30,text={str='Dim all Assigned Custom Colors',style=2,align=4,col={180,180,181}}})

Button:new(_pageColor_und, {x=28,y=545,w=30,img='color_dim_all',imgType=3,action=reduceCustCol,param=true})
Element:new(_pageColor_und, {x=63,y=545,w=210,h=30,text={str='Dim Colors on Selected Tracks',style=2,align=4,col={180,180,181}}})

Button:new(_pageColor_und, {x=28,y=584,w=30,img='bin',imgType=3,action=setTrackDefaultColor})
Element:new(_pageColor_und, {x=63,y=583,w=210,h=30,text={str='RESET Selected Tracks to Default Col.',style=2,align=4,col={180,180,181}}})

Button:new(_pageColor_und, {x=280,y=507,w=30,img='color_picker',imgType=3,action=TrackCustomColor})
Element:new(_pageColor_und, {x=313,y=507,w=210,h=30,text={str='Track: Set to Custom Color (Picker)',style=2,align=4,col={180,180,181}}})

Button:new(_pageColor_und, {x=280,y=545,w=30,img='color_random',imgType=3,action=TrackRandomColor})
Element:new(_pageColor_und, {x=313,y=545,w=210,h=30,text={str='Track: Set to Random Colors (16)',style=2,align=4,col={180,180,181}}})

Button:new(_pageColor_und, {x=280,y=584,w=30,img='bin',imgType=3,action=resetRandomGenerator})
Element:new(_pageColor_und, {x=313,y=583,w=210,h=30,text={str='Color: Reset Random Generator',style=2,align=4,col={180,180,181}}})


--ENV & TRANSPORT PAGE
_pageEnvTrans_und = Element:new(_subPageContainer, {x=0,y=40,w=513,h=639,helpL=helpL_layout})
apply.und.envcp = {Button:new(_pageEnvTrans_und, {x=186,y=2,w=61,img='apply_100',imgType=3,action=applyLayout,param={'envcp',''},helpL=helpL_applySize})}
apply.und.envcp[2] = Button:new(_pageEnvTrans_und, {x=228,y=2,w=61,img='apply_150',imgType=3,action=applyLayout,param={'envcp','150%_'},helpL=helpL_applySize,visible=false}) -- NA
apply.und.envcp[3] = Button:new(_pageEnvTrans_und, {x=270,y=2,w=61,img='apply_200',imgType=3,action=applyLayout,param={'envcp','200%_'},helpL=helpL_applySize})
Spinner:new(_pageEnvTrans_und, {x=95,y=55,w=124,title='NAME SIZE',action=paramSet,param='envcp_labelSize',valsTable=envcpLabelVals,helpR=helpR_nameSizeEnv})
Spinner:new(_pageEnvTrans_und, {x=281,y=55,w=124,title='FADER SIZE',action=paramSet,param='envcp_fader_size',valsTable=tcpVolVals})
Button:new(_pageEnvTrans_und, {flow=false,x=150,y=104,w=30,img='check-buttons_check_purple',imgType=3,action=paramToggle,param='envcp_folder_indent',helpR=helpR_emvMatchIndent})
Element:new(_pageEnvTrans_und, {x=178,y=104,w=200,h=30,text={str='Match Track Folder Indent/Align',style=3,align=4,col={180,180,181}},helpR=helpR_emvMatchIndent})

Element:new(_pageEnvTrans_und, {x=165,y=222,w=183,h=23,img='transport_title'})
Element:new(_pageEnvTrans_und, {x=0,y=256,w=513,h=1,color={116,128,149,225}}) -- title div
apply.und.trans = {Button:new(_pageEnvTrans_und, {x=186,y=278,w=61,img='apply_100',imgType=3,action=applyLayout,param={'trans',''},helpL=helpL_applySize})}
apply.und.trans[2] = Button:new(_pageEnvTrans_und, {x=228,y=278,w=61,img='apply_150',imgType=3,action=applyLayout,param={'trans','150%_'},helpL=helpL_applySize,visible=false}) -- NA
apply.und.trans[3] = Button:new(_pageEnvTrans_und, {x=270,y=278,w=61,img='apply_200',imgType=3,action=applyLayout,param={'trans','200%_'},helpL=helpL_applySize})

Element:new(_pageEnvTrans_und, {x=154,y=322,w=200,h=16,text={str='* See Help text >>>',style=3,align=5,col={160,160,161}}})
Spinner:new(_pageEnvTrans_und, {x=10,y=352,w=149,title='ACTIONS *',action=paramSet,param='trans_actionButton',valsTable=transActBtnVals,helpR=helpR_showActBtnTrans,helpL=helpL_layout})
Spinner:new(_pageEnvTrans_und, {x=180,y=352,w=149,title='CUSTOM BTNS *',action=paramSet,param='trans_metroButton',valsTable=transMetroBtnVals,helpR=helpR_showMetroBtnTrans,helpL=helpL_layout})
Spinner:new(_pageEnvTrans_und, {x=348,y=352,w=149,title='PLAY RATE *',action=paramSet,param='trans_rate_size',valsTable=transRateVals,helpR=help_playRate,helpL=helpL_layout})

_transPrefsStroke = Element:new(_pageEnvTrans_und, {x=0,y=415,w=513,h=176,color={116,128,149,225}}) -- stroke
_transPrefs = Element:new(_transPrefsStroke, {x=1,y=1,w=511,h=174,color={39,41,43},helpL=help_pref}) -- fill

Button:new(_transPrefs, {x=29,y=26,img='check-buttons_check_purple',imgType=3,action=actionToggle,param=40533})
Element:new(_transPrefs, {x=68,y=26,w=150,h=30,text={str='Center Transport',style=2,align=4,col={180,180,181}}})
Button:new(_transPrefs, {x=29,y=69,img='check-buttons_check_purple',imgType=3,action=actionToggle,param=40531})
Element:new(_transPrefs, {x=68,y=69,w=150,h=30,text={str='Show Play Rate',style=2,align=4,col={180,180,181}}})
Button:new(_transPrefs, {x=29,y=112,img='check-buttons_check_purple',imgType=3,action=actionToggle,param=40680})
Element:new(_transPrefs, {x=68,y=112,w=170,h=30,text={str='Show Time Signature',style=2,align=4,col={180,180,181}}})
Button:new(_transPrefs, {x=285,y=26,img='check-buttons_check_purple',imgType=3,action=actionToggle,param=40868})
Element:new(_transPrefs, {x=324,y=26,w=170,h=30,text={str='Use Home/End for Markers',style=2,align=4,col={180,180,181}}})
Button:new(_transPrefs, {x=285,y=69,img='check-buttons_check_purple',imgType=3,action=actionToggle,param=40532})
Element:new(_transPrefs, {x=324,y=69,w=170,h=30,text={str='Show Play State as Text',style=2,align=4,col={180,180,181}}})
Button:new(_transPrefs, {x=285,y=112,img='check-buttons_check_purple',imgType=3,action=actionToggle,param=40620})
Element:new(_transPrefs, {x=324,y=112,w=170,h=30,text={str='External Timecode Sync.',style=2,align=4,col={180,180,181}}})

--HELP
_helpL = Element:new(_pageContainer, {x=-144,y=500,w=115,h=200,text={str='',style=2,align=2,wrap=true,vCenter=false,lineSpacing=14,col={170,170,204}}})
Element:new(_helpL, {x=18,y=-25,w=97,h=19,img='helpHeader_l'})
_helpR = Element:new(_pageContainer, {x=542,y=200,w=115,h=200,text={str='Show play state',style=2,align=0,wrap=true,vCenter=false,lineSpacing=14,col={170,170,204}}})
Element:new(_helpR, {x=0,y=-25,w=97,h=19,img='helpHeader_r'})

  --------- RUNLOOP ---------

needReaperStateUpdate = 1
paramGet = 1
resize = 1
redraw = 1
lastchgidx = 0
chgsel = 1
oldTheme = nil
isGenericTheme = false -- CSIX custom adjuster
mouseXold = 0
mouseYold = 0
mouseWheelAccum = 0 -- accumulated unused wheeling
trackNames = {}
trackNamesW = {}
envcp_LabelMeasureIdx = nil
tcpLayouts = {}
envs = {}
selectedTracks = {}
activeMouseElement = nil
_helpL.y, _helpR.y = 10000,10000
editPage = tonumber(reaper.GetExtState(sTitle,'editPage')) or 1
editPage2 = tonumber(reaper.GetExtState(sTitle,'editPage2')) or 1 -- for non-def themes
drawScale = 1

indexParams()
themeCheck()
getDock()
doActivePage()
doActiveLayout()
doHelpVis()

function runloop()

  themeCheck()
  --getDock()
  getDpi()

  chgidx = reaper.GetProjectStateChangeCount(0)
  if chgidx ~= lastchgidx then
    if #trackNames ~= (reaper.CountTracks(0)-1) then -- the track count has changed, rebuild from scratch
      trackNames = {}
      envs = {}
      tcpLayouts = {}
      selectedTracks = {}
    end
    needReaperStateUpdate = 1
    lastchgidx = chgidx
  end

  if needReaperStateUpdate == 1 then
    doActivePage()
    local trackCount = reaper.CountTracks(0)-1
    measureTrackNames(trackCount)
    measureEnvNames(trackCount)
    redraw = 1
  end
  needReaperStateUpdate_cnt = (needReaperStateUpdate_cnt or 0) + 1
  if needReaperStateUpdate == 1 or needReaperStateUpdate_cnt > 3 then
    getReaperDpi()
    root:doUpdateState()
    needReaperStateUpdate_cnt = 0
    needReaperStateUpdate = 0
  end
    
  local currentTrack = getSelectedTrack()
  if currentTrack ~= lastSelectedTrack then
    lastSelectedTrack = currentTrack

    updateTrackSound() --only on selection change
    updateTcpPageOverlay()  --basic narrow tcp A only
    updateTcpBtnOlHelp()  --basic narrow tcp A only
    updateTcpBtnOverlay()  --basic narrow tcp A only
  end

  -- mouse stuff
  local isCap = (gfx.mouse_cap&1)
  now = reaper.time_precise()
  
  if gfx.mouse_x ~= mouseXold or gfx.mouse_y ~= mouseYold or (firstClick ~= nil and last_click_time ~= nil and last_click_time+.4 < now) then
    firstClick = nil
  end
  
  if gfx.mouse_x ~= mouseXold or gfx.mouse_y ~= mouseYold or isCap ~= mouseCapOld or gfx.mouse_wheel ~= 0  then
    local wheel_amt = 0
    if gfx.mouse_wheel ~= 0 then
      mouseWheelAccum = mouseWheelAccum + gfx.mouse_wheel
      gfx.mouse_wheel = 0
      wheel_amt = math.floor(mouseWheelAccum / 120 + 0.5)
      if wheel_amt ~= 0 then mouseWheelAccum = 0 end
    end

    local hit = root:hitTest(gfx.mouse_x,gfx.mouse_y)
    if isCap == 0 and mouseCapOld == 1 then -- mouse-up
      if activeMouseElement ~= nil and hit == activeMouseElement then -- still over element
        activeMouseElement:mouseUp(gfx.mouse_x,gfx.mouse_y)
      end
      if activeMouseElement ~= nil and activeMouseElement.dragStart ~= nil then
        activeMouseElement.dragStart, activeMouseElement.dragStartValue = nil, nil
      end
    end

    if isCap == 0 or mouseCapOld == 0 then -- uncaptured mouse-down or mouse-move
      if activeMouseElement ~= nil and activeMouseElement ~= hit then
        activeMouseElement:mouseAway()
      end
      activeMouseElement = hit
      doHelp()
    end

    if activeMouseElement ~= nil then

      if isCap == 0 or mouseCapOld == 0 then -- uncaptured mouse-down or mouse-move
        activeMouseElement:mouseOver()
      end
      if wheel_amt ~= 0 then
        activeMouseElement:mouseWheel(wheel_amt)
      end
      
      if isCap == 1 then
        local x,y = gfx.mouse_x,gfx.mouse_y
        activeMouseElement:mouseDown(gfx.mouse_x,gfx.mouse_y)
        
        if firstClick == nil or last_click_time == nil then 
          firstClick = {gfx.mouse_x,gfx.mouse_y}
          last_click_time = now
        else if now < last_click_time+.4 and math.abs((x-firstClick[1])*(x-firstClick[1]) + (y- firstClick[2])*(y- firstClick[2])) < 4 then 
          activeMouseElement:doubleClick() 
          firstClick = nil
          else
            firstClick = nil
          end 
        end
          
      end
      
    end
    mouseXold, mouseYold, mouseCapOld = gfx.mouse_x, gfx.mouse_y, isCap
  end

  if paramGet == 1 then
    root:doParamGet()
    if paramsIdx and paramsIdx.A then
    refreshMasterColor() end
    if isGenericTheme == true then doGenericParams() end
    paramGet = 0
  end

  if resize == 1 or root.drawW ~= gfx.w*drawScale_inv_mac or root.drawH ~= gfx.h*drawScale_inv_mac then -- window resized
    root.drawW, root.drawH = gfx.w*drawScale_inv_mac,gfx.h*drawScale_inv_mac
    root:onSize()
    root:draw()
    resize,redraw = 0,0
  elseif redraw == 1 then
    root:draw()
    redraw = 0
  end

  if ctheme_param_needsave ~= nil then
    if (gfx.mouse_cap&1)==0 and (ctheme_param_needsave[2] == nil or now > ctheme_param_needsave[2]) then
      local tmp,tmp,value = reaper.ThemeLayout_GetParameter(ctheme_param_needsave[1])
      reaper.ThemeLayout_SetParameter(ctheme_param_needsave[1],value,true) 
      ctheme_param_needsave = nil
    end
  end

  gfx.update()
  local c = gfx.getchar()
  if c >= 0 then
    if c == 25 or (c == 26 and (gfx.mouse_cap&8)==8) then  -- ctrl+y or ctrl+shift+z
      reaper.Main_OnCommand(40030,0) -- redo
    elseif c == 26 then -- ctrl+z
      reaper.Main_OnCommand(40029,0) -- undo
    end
    reaper.runloop(runloop)
  end
end

gfx.clear = 0x454545
getDpi()
runloop()
redraw = 1 -- temporary workaround of REAPER bug

function storeTable(title,table,parent)
  for i, v in pairs(table) do
    local p = ''
    if parent~=nil then p = parent..'.' end
    if type(v)=='table' then storeTable(title,v,i) else reaper.SetExtState(sTitle,title..'.'..p..i,v,true) end
  end
end

function Quit()
  d,x,y,w,h=gfx.dock(-1,0,0,0,0)
  reaper.SetExtState(sTitle,'dock',d,true)
  reaper.SetExtState(sTitle,'wndx',x,true)
  reaper.SetExtState(sTitle,'wndy',y,true)
  reaper.SetExtState(sTitle,'editPage',editPage,true)
  reaper.SetExtState(sTitle,'editPage2',editPage2,true)
  reaper.SetExtState(sTitle,'paletteCurrent',palette.current,true)
  reaper.SetExtState(sTitle,'activeLayoutTcp',activeLayout.tcp,true)
  reaper.SetExtState(sTitle,'activeLayoutMcp',activeLayout.mcp,true)
  gfx.quit()
end
reaper.atexit(Quit)
