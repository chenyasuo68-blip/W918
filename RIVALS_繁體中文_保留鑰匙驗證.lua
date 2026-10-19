pcall(function()
	if shared._4VJShopRivals then shared._4VJShopRivals:cleanup() end
end)
for _, n in ipairs({"4VJKeySystem","4VJShopGUI"}) do
	local o = game:GetService("CoreGui"):FindFirstChild(n)
	if o then o:Destroy() end
end

-- ═══════════════════════════════════════
-- Services & helpers
-- ═══════════════════════════════════════
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInput = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local GuiService = game:GetService("GuiService")
local TeleportService = game:GetService("TeleportService")
local HttpService = game:GetService("HttpService")
local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera
local mouse = LP:GetMouse()

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	if workspace.CurrentCamera then Cam = workspace.CurrentCamera end
end)

local function rgb(r,g,b) return Color3.fromRGB(r,g,b) end
local function tw(o,p,d,s,dir)
	local t = TweenService:Create(o, TweenInfo.new(d or 0.2, s or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), p)
	t:Play() return t
end
local function corner(p,r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 8); c.Parent=p; return c end
local function stroke(p,c,t) local s=Instance.new("UIStroke"); s.Color=c; s.Thickness=t or 1; s.ApplyStrokeMode=Enum.ApplyStrokeMode.Border; s.Parent=p; return s end
local function pad(p,t,b,l,r) local u=Instance.new("UIPadding"); u.PaddingTop=UDim.new(0,t or 0); u.PaddingBottom=UDim.new(0,b or 0); u.PaddingLeft=UDim.new(0,l or 0); u.PaddingRight=UDim.new(0,r or 0); u.Parent=p; return u end
local function grad(p, colors, rot)
	local g = Instance.new("UIGradient")
	g.Color = colors
	g.Rotation = rot or 0
	g.Parent = p
	return g
end

-- ═══════════════════════════════════════
-- PALETTES (plusieurs)
-- ═══════════════════════════════════════
local Palettes = {
	BlackPurple = {
		bg=rgb(10,10,14), panel=rgb(16,16,22), card=rgb(22,22,30), cardH=rgb(30,30,42),
		border=rgb(40,40,55), text=rgb(234,238,248), dim=rgb(130,130,155),
		accent=rgb(140,0,255), accent2=rgb(100,0,200), bad=rgb(255,110,130),
		g1=rgb(140,0,255), g2=rgb(80,0,200), g3=rgb(200,100,255),
	},
	Midnight = {
		bg=rgb(8,12,20), panel=rgb(14,20,32), card=rgb(20,28,44), cardH=rgb(32,44,64),
		border=rgb(50,70,100), text=rgb(220,235,255), dim=rgb(150,170,200),
		accent=rgb(0,180,255), accent2=rgb(0,120,200), bad=rgb(255,80,80),
		g1=rgb(0,180,255), g2=rgb(0,100,200), g3=rgb(100,200,255),
	},
	Neon = {
		bg=rgb(12,12,16), panel=rgb(20,20,28), card=rgb(28,28,40), cardH=rgb(40,40,56),
		border=rgb(60,60,80), text=rgb(240,240,255), dim=rgb(180,180,200),
		accent=rgb(0,255,200), accent2=rgb(0,200,150), bad=rgb(255,70,120),
		g1=rgb(0,255,200), g2=rgb(0,180,120), g3=rgb(150,255,220),
	},
	Royal = {
		bg=rgb(16,8,24), panel=rgb(28,16,40), card=rgb(40,24,56), cardH=rgb(56,36,76),
		border=rgb(80,60,100), text=rgb(240,230,255), dim=rgb(180,160,200),
		accent=rgb(255,100,200), accent2=rgb(200,60,150), bad=rgb(255,80,80),
		g1=rgb(255,100,200), g2=rgb(180,40,140), g3=rgb(255,180,240),
	},
}

local activePalette = "BlackPurple"
local P = setmetatable({}, {__index=function(_,k) return Palettes[activePalette][k] end})

-- ═══════════════════════════════════════
-- LANGUE (complète)
-- ═══════════════════════════════════════
local activeLang = "zh"
local Languages = {
	{code="fr",name="Français",flag="🇫🇷"}, {code="en",name="English",flag="🇬🇧"},
	{code="es",name="Español",flag="🇪🇸"},  {code="pt",name="Português",flag="🇵🇹"},
	{code="de",name="Deutsch",flag="🇩🇪"},  {code="it",name="Italiano",flag="🇮🇹"},
	{code="ru",name="Русский",flag="🇷🇺"},  {code="tr",name="Türkçe",flag="🇹🇷"},
	{code="ja",name="日本語",flag="🇯🇵"},   {code="zh",name="繁體中文",flag="🇹🇼"},
	{code="ko",name="한국어",flag="🇰🇷"},   {code="ar",name="العربية",flag="🇸🇦"},
}
local Tr = {
	-- Noms des onglets
	["Combat"]={fr="Combat",en="Combat",es="Combate",pt="Combate",de="Kampf",it="Combattimento",ru="Бой",tr="Savaş",ja="戦闘",zh="戰鬥",ko="전투",ar="قتال"},
	["ESP"]={fr="ESP",en="ESP",es="ESP",pt="ESP",de="ESP",it="ESP",ru="ESP",tr="ESP",ja="ESP",zh="ESP",ko="ESP",ar="ESP"},
	["Movement"]={fr="Mouvement",en="Movement",es="Movimiento",pt="Movimento",de="Bewegung",it="Movimento",ru="Движение",tr="Hareket",ja="移動",zh="移動",ko="이동",ar="حركة"},
	["Visuals"]={fr="Visuels",en="Visuals",es="Visuales",pt="Visuais",de="Visuell",it="Visivi",ru="Визуал",tr="Görsel",ja="視覚",zh="視覺",ko="시각",ar="مرئي"},
	["Unlock"]={fr="Déblocage",en="Unlock",es="Desbloquear",pt="Desbloquear",de="Freischalten",it="Sblocca",ru="Разблок",tr="Aç",ja="解除",zh="解鎖",ko="해제",ar="فتح"},
	["Misc"]={fr="Divers",en="Misc",es="Varios",pt="Diversos",de="Sonstiges",it="Varie",ru="Разное",tr="Diğer",ja="その他",zh="其他",ko="기타",ar="متفرق"},
	["Style"]={fr="Style",en="Style",es="Estilo",pt="Estilo",de="Stil",it="Stile",ru="Стиль",tr="Stil",ja="スタイル",zh="樣式",ko="스타일",ar="نمط"},
	-- Sections
	["Aimbot"]={fr="Aimbot",en="Aimbot",es="Aimbot",pt="Aimbot",de="Aimbot",it="Aimbot",ru="Аимбот",tr="Aimbot",ja="エイムボット",zh="自動瞄準",ko="에임봇",ar="توجيه"},
	["Silent Aim"]={fr="Silent Aim",en="Silent Aim",es="Silent Aim",pt="Silent Aim",de="Silent Aim",it="Silent Aim",ru="Сайлент",tr="Silent Aim",ja="サイレントエイム",zh="靜默瞄準",ko="사일런트 에임",ar="تصويب صامت"},
	["Automation"]={fr="Automatisation",en="Automation",es="Automatización",pt="Automação",de="Automatisierung",it="Automazione",ru="Автоматизация",tr="Otomasyon",ja="自動化",zh="自動化",ko="자동화",ar="أتمتة"},
	["FOV"]={fr="FOV",en="FOV",es="FOV",pt="FOV",de="FOV",it="FOV",ru="FOV",tr="FOV",ja="FOV",zh="視野",ko="FOV",ar="مجال الرؤية"},
	["Player ESP"]={fr="ESP Joueur",en="Player ESP",es="ESP Jugador",pt="ESP Jogador",de="Spieler ESP",it="ESP Giocatore",ru="ESP игрока",tr="Oyuncu ESP",ja="プレイヤーESP",zh="玩家透視",ko="플레이어 ESP",ar="ESP اللاعب"},
	["Chams"]={fr="Chams",en="Chams",es="Chams",pt="Chams",de="Chams",it="Chams",ru="Chams",tr="Chams",ja="Chams",zh="透視高亮",ko="챔스",ar="تشامس"},
	["Speed"]={fr="Vitesse",en="Speed",es="Velocidad",pt="Velocidade",de="Geschwindigkeit",it="Velocità",ru="Скорость",tr="Hız",ja="速度",zh="速度",ko="속도",ar="سرعة"},
	["Fly"]={fr="Vol",en="Fly",es="Vuelo",pt="Voo",de="Fliegen",it="Volo",ru="Полёт",tr="Uçuş",ja="飛行",zh="飛行",ko="비행",ar="طيران"},
	["Physics"]={fr="Physique",en="Physics",es="Física",pt="Física",de="Physik",it="Fisica",ru="Физика",tr="Fizik",ja="物理",zh="物理",ko="물리",ar="فيزياء"},
	["Tweaks"]={fr="Réglages",en="Tweaks",es="Ajustes",pt="Ajustes",de="Tweaks",it="Regolazioni",ru="Настройки",tr="Ayarlar",ja="調整",zh="調整",ko="조정",ar="تعديلات"},
	["Freecam"]={fr="Freecam",en="Freecam",es="Freecam",pt="Freecam",de="Freecam",it="Freecam",ru="Freecam",tr="Freecam",ja="フリーカム",zh="自由視角",ko="프리캠",ar="كاميرا حرة"},
	["Lighting"]={fr="Éclairage",en="Lighting",es="Iluminación",pt="Iluminação",de="Beleuchtung",it="Illuminazione",ru="Освещение",tr="Aydınlatma",ja="照明",zh="光照",ko="조명",ar="إضاءة"},
	["Camera"]={fr="Caméra",en="Camera",es="Cámara",pt="Câmera",de="Kamera",it="Fotocamera",ru="Камера",tr="Kamera",ja="カメラ",zh="鏡頭",ko="카메라",ar="كاميرا"},
	["Crosshair"]={fr="Viseur",en="Crosshair",es="Mira",pt="Mira",de="Fadenkreuz",it="Mirino",ru="Прицел",tr="Nişan",ja="照準",zh="準星",ko="조준선",ar="شاشة"},
	["World"]={fr="Monde",en="World",es="Mundo",pt="Mundo",de="Welt",it="Mondo",ru="Мир",tr="Dünya",ja="世界",zh="世界",ko="세계",ar="عالم"},
	["Cosmetics"]={fr="Cosmétiques",en="Cosmetics",es="Cosméticos",pt="Cosméticos",de="Kosmetik",it="Cosmetici",ru="Косметика",tr="Kozmetik",ja="コスメ",zh="外觀",ko="코스메틱",ar="تجميل"},
	["Utility"]={fr="Utilitaires",en="Utility",es="Utilidad",pt="Utilidade",de="Dienstprogramm",it="Utilità",ru="Утилиты",tr="Araçlar",ja="ユーティリティ",zh="工具",ko="유틸리티",ar="أدوات"},
	["HUD"]={fr="HUD",en="HUD",es="HUD",pt="HUD",de="HUD",it="HUD",ru="HUD",tr="HUD",ja="HUD",zh="HUD",ko="HUD",ar="HUD"},
	["Queue"]={fr="File d'attente",en="Queue",es="Cola",pt="Fila",de="Warteschlange",it="Coda",ru="Очередь",tr="Sıra",ja="キュー",zh="佇列",ko="대기열",ar="طابور"},
	["Palette"]={fr="Palette",en="Palette",es="Paleta",pt="Paleta",de="Palette",it="Paletta",ru="Палитра",tr="Palet",ja="パレット",zh="配色",ko="팔레트",ar="لوحة"},
	["About"]={fr="À propos",en="About",es="Acerca de",pt="Sobre",de="Über",it="Informazioni",ru="О нас",tr="Hakkında",ja="について",zh="關於",ko="정보",ar="حول"},
	-- Traductions chinoises traditionnelles des contrôles
	["Aim Mode"]={zh="瞄準模式"},
	["Hold RMB"]={zh="按住滑鼠右鍵"},
	["Hold LMB"]={zh="按住滑鼠左鍵"},
	["Always"]={zh="持續"},
	["Prediction"]={zh="預測"},
	["Wall Check"]={zh="遮擋檢查"},
	["Team Check"]={zh="隊伍檢查"},
	["Smoothing"]={zh="平滑度"},
	["Target Bone"]={zh="瞄準部位"},
	["Head"]={zh="頭部"},
	["HumanoidRootPart"]={zh="角色根部"},
	["UpperTorso"]={zh="上半身"},
	["Priority"]={zh="優先目標"},
	["Closest"]={zh="最近"},
	["LowestHP"]={zh="最低生命值"},
	["Distance"]={zh="距離"},
	["Hit Chance"]={zh="命中機率"},
	["Triggerbot"]={zh="自動扳機"},
	["Trigger Delay (ms)"]={zh="觸發延遲（毫秒）"},
	["Auto Shoot"]={zh="自動射擊"},
	["Aim Lock"]={zh="鎖定瞄準"},
	["Auto Clicker"]={zh="自動點擊"},
	["Clicks / Sec"]={zh="每秒點擊次數"},
	["Show FOV Circle"]={zh="顯示視野圓圈"},
	["FOV Radius"]={zh="視野半徑"},
	["FOV Color"]={zh="視野顏色"},
	["Mint"]={zh="薄荷綠"},
	["Blue"]={zh="藍色"},
	["Pink"]={zh="粉紅色"},
	["White"]={zh="白色"},
	["Yellow"]={zh="黃色"},
	["Enable ESP"]={zh="啟用玩家透視"},
	["Boxes"]={zh="方框"},
	["Names"]={zh="名稱"},
	["Health Bars"]={zh="生命條"},
	["Tracers"]={zh="追蹤線"},
	["Head Dot"]={zh="頭部標記"},
	["Snaplines"]={zh="連線"},
	["Off-Screen Arrows"]={zh="螢幕外方向箭頭"},
	["Chams (Highlights)"]={zh="角色透視高亮"},
	["Speed Hack"]={zh="速度調整"},
	["Walk Speed"]={zh="移動速度"},
	["Auto Sprint"]={zh="自動衝刺"},
	["Noclip"]={zh="穿牆"},
	["Infinite Jump"]={zh="無限跳躍"},
	["Bunny Hop"]={zh="連續跳躍"},
	["Long Jump"]={zh="遠跳"},
	["Long Jump Force"]={zh="遠跳力度"},
	["TP to Mouse (Alt+Click)"]={zh="傳送至游標（Alt＋點擊）"},
	["Air Jump"]={zh="空中跳躍"},
	["Spider Climb"]={zh="攀牆"},
	["Anti Fall Damage"]={zh="防止墜落傷害"},
	["Custom Jump Power"]={zh="自訂跳躍力度"},
	["Jump Power"]={zh="跳躍力度"},
	["Custom Gravity"]={zh="自訂重力"},
	["Gravity"]={zh="重力"},
	["Freecam Speed"]={zh="自由視角速度"},
	["Fullbright"]={zh="全亮"},
	["No Fog"]={zh="移除霧效"},
	["FOV Changer"]={zh="視野調整"},
	["Camera FOV"]={zh="鏡頭視野"},
	["Third Person"]={zh="第三人稱"},
	["Custom Crosshair"]={zh="自訂準星"},
	["Size"]={zh="大小"},
	["Thickness"]={zh="粗細"},
	["Hitmarker"]={zh="命中標記"},
	["Day/Night"]={zh="日／夜"},
	["Time of Day"]={zh="時間"},
	["No Textures"]={zh="移除材質"},
	["No Kill Cam"]={zh="停用死亡回放"},
	["Débloque skins/wraps/charms dans le menu."]={zh="在選單中解鎖造型／塗裝／掛飾。"},
	["Unlock All Cosmetics"]={zh="解鎖所有外觀"},
	["Anti-AFK"]={zh="防止閒置"},
	["Auto Respawn"]={zh="自動重生"},
	["Instant Respawn"]={zh="立即重生"},
	["Spectate Alert"]={zh="觀戰通知"},
	["FPS Counter"]={zh="FPS 計數器"},
	["Ping Counter"]={zh="延遲計數器"},
	["Watermark"]={zh="浮水印"},
	["Auto Queue Unrated"]={zh="自動加入非排名配對"},
}
local function tr(s)
	if activeLang == "en" then return s end
	local e = Tr[s]
	if e and e[activeLang] then return e[activeLang] end
	return s
end

-- ═══════════════════════════════════════
-- FEATURE STATE
-- ═══════════════════════════════════════
local S = {
	aimbotOn=false, aimSmooth=3, aimBone="Head", aimPred=true, aimMode="Hold RMB",
	aimWall=false, aimTeam=true, silentOn=false, hitChance=100,
	trigOn=false, trigDelay=50, autoShoot=false, autoClick=false, cps=12,
	fovShow=false, fovRadius=200, fovColor=P.accent, aimLock=false, priority="Closest",
	espOn=false, espBox=true, espName=true, espHp=true, espDist=true,
	espTrace=false, espTeam=true, chams=false, headDot=false, snaplines=false, arrows=false,
	speedOn=false, speedVal=22, flyOn=false, flySpd=60, noclipOn=false,
	infJump=false, bhop=false, longJump=false, longVal=80, sprint=false,
	tpMouse=false, airJump=false, antiFall=false, jpOn=false, jpVal=50,
	gravOn=false, gravVal=196, spider=false, freecam=false, freecamSpd=2,
	fullbright=false, noFog=false, camFov=false, camFovVal=100, tps=false,
	xhair=false, xhairSize=6, xhairThick=1, hitmark=false, ambient=false,
	ambientTime=14, noTex=false, noKillCam=false,
	afk=true, autoRes=false, instRes=false, specAlert=false,
	fpsHud=false, pingHud=false, watermark=true,
}

-- ═══════════════════════════════════════
-- UTILITAIRES JEU
-- ═══════════════════════════════════════
local function alive(p)
	local c=p.Character; if not c then return false end
	local h=c:FindFirstChildOfClass("Humanoid")
	local hrp=c:FindFirstChild("HumanoidRootPart")
	return h and hrp and h.Health>0
end
local function sameTeamR(p) return LP.Team and p.Team and LP.Team==p.Team end
local function espSameTeam(p) return S.espTeam and sameTeamR(p) end
local function combatSameTeam(p) return S.aimTeam and sameTeamR(p) end
local function bonePos(c,name)
	local pt=c:FindFirstChild(name); if pt then return pt.Position end
	local h=c:FindFirstChild("Head"); if h then return h.Position end
	local hrp=c:FindFirstChild("HumanoidRootPart"); if hrp then return hrp.Position end
	return nil
end
local function visible(o,t,c)
	local rp=RaycastParams.new()
	rp.FilterType=Enum.RaycastFilterType.Exclude
	rp.FilterDescendantsInstances={LP.Character,Cam,c}
	return workspace:Raycast(o, t-o, rp)==nil
end
local function closest()
	local best,bestScore,bestPos=nil,math.huge,nil
	local mp=UserInput:GetMouseLocation()
	local op=Cam.CFrame.Position
	for _,p in ipairs(Players:GetPlayers()) do
		if p==LP or combatSameTeam(p) or not alive(p) then continue end
		local c=p.Character; if not c then continue end
		local bp=bonePos(c,S.aimBone); if not bp then continue end
		local sp,os=Cam:WorldToViewportPoint(bp)
		if not os or sp.Z<=0 then continue end
		local d=(Vector2.new(sp.X,sp.Y)-mp).Magnitude
		if d>S.fovRadius then continue end
		if S.aimWall and not visible(op,bp,c) then continue end
		local score=d
		if S.priority=="LowestHP" then
			local h=c:FindFirstChildOfClass("Humanoid"); score=h and h.Health or math.huge
		elseif S.priority=="Distance" then score=(op-bp).Magnitude end
		if score<bestScore then best,bestScore,bestPos=p,score,bp end
	end
	return best,bestScore,bestPos
end
local function partToPlayer(pt)
	if not pt then return nil end
	local c=pt
	while c and c~=workspace do
		local p=Players:GetPlayerFromCharacter(c); if p then return p end
		c=c.Parent
	end
	return nil
end
local function fire()
	if mouse1press and mouse1release then
		mouse1press(); task.delay(0.03, function() pcall(mouse1release) end)
	elseif mouse1click then mouse1click() end
end

-- ═══════════════════════════════════════
-- KEY SCREEN (avec logo)
-- ═══════════════════════════════════════
local VALID_KEY = "Unlock-FFP12094"
local keyGui = Instance.new("ScreenGui")
keyGui.Name = "4VJKeySystem"
keyGui.ResetOnSpawn = false
keyGui.IgnoreGuiInset = true
keyGui.DisplayOrder = 9999
pcall(function() keyGui.Parent = CoreGui end)
if not keyGui.Parent then keyGui.Parent = LP:WaitForChild("PlayerGui") end

local kDim = Instance.new("Frame")
kDim.Size = UDim2.new(1,0,1,0)
kDim.BackgroundColor3 = rgb(5,6,12)
kDim.BackgroundTransparency = 0.35
kDim.BorderSizePixel = 0
kDim.Parent = keyGui

local kGradFrame = Instance.new("Frame")
kGradFrame.Size = UDim2.new(1,0,1,0)
kGradFrame.BackgroundColor3 = rgb(140,0,255)
kGradFrame.BackgroundTransparency = 0.88
kGradFrame.BorderSizePixel = 0
kGradFrame.Parent = kDim
local kBgGrad = Instance.new("UIGradient")
kBgGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, rgb(140,0,255)),
	ColorSequenceKeypoint.new(0.5, rgb(80,0,200)),
	ColorSequenceKeypoint.new(1, rgb(200,100,255)),
})
kBgGrad.Rotation = 0
kBgGrad.Parent = kGradFrame

local kCard = Instance.new("Frame")
kCard.Size = UDim2.new(0, 420, 0, 280)
kCard.Position = UDim2.new(0.5, -210, 0.5, -140)
kCard.BackgroundColor3 = rgb(10,10,14)
kCard.BackgroundTransparency = 0.02
kCard.BorderSizePixel = 0
kCard.Parent = kDim
corner(kCard, 16)
local kCardStroke = stroke(kCard, rgb(140,0,255), 2)

local kTopStrip = Instance.new("Frame")
kTopStrip.Size = UDim2.new(1, -40, 0, 3)
kTopStrip.Position = UDim2.new(0, 20, 0, 0)
kTopStrip.BackgroundColor3 = rgb(140,0,255)
kTopStrip.BorderSizePixel = 0
kTopStrip.Parent = kCard
corner(kTopStrip, 2)
local kStripGrad = Instance.new("UIGradient")
kStripGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, rgb(140,0,255)),
	ColorSequenceKeypoint.new(0.5, rgb(80,0,200)),
	ColorSequenceKeypoint.new(1, rgb(200,100,255)),
})
kStripGrad.Parent = kTopStrip

local kLogo = Instance.new("TextLabel")
kLogo.Size = UDim2.new(0, 72, 0, 72)
kLogo.Position = UDim2.new(0.5, -36, 0, 22)
kLogo.BackgroundColor3 = rgb(140,0,255)
kLogo.BackgroundTransparency = 0.86
kLogo.Text = "💎"
kLogo.Font = Enum.Font.GothamBold
kLogo.TextSize = 50
kLogo.TextColor3 = rgb(140,0,255)
kLogo.Parent = kCard
corner(kLogo, 18)

local kTitle = Instance.new("TextLabel")
kTitle.Size = UDim2.new(1, 0, 0, 28)
kTitle.Position = UDim2.new(0, 0, 0, 100)
kTitle.BackgroundTransparency = 1
kTitle.Text = "4VJ SHOP"
kTitle.Font = Enum.Font.GothamBlack
kTitle.TextSize = 26
kTitle.TextColor3 = rgb(240,244,252)
kTitle.Parent = kCard

local kSub = Instance.new("TextLabel")
kSub.Size = UDim2.new(1, 0, 0, 16)
kSub.Position = UDim2.new(0, 0, 0, 128)
kSub.BackgroundTransparency = 1
kSub.Text = "⚔️ RIVALS HUB · v1 paid"
kSub.Font = Enum.Font.GothamMedium
kSub.TextSize = 11
kSub.TextColor3 = rgb(140,130,160)
kSub.Parent = kCard

local kInputBg = Instance.new("Frame")
kInputBg.Size = UDim2.new(1, -50, 0, 44)
kInputBg.Position = UDim2.new(0, 25, 0, 160)
kInputBg.BackgroundColor3 = rgb(18,18,26)
kInputBg.BorderSizePixel = 0
kInputBg.Parent = kCard
corner(kInputBg, 12)
local kInputStroke = stroke(kInputBg, rgb(60,60,80), 1)

local kKeyIcon = Instance.new("TextLabel")
kKeyIcon.Size = UDim2.new(0, 30, 1, 0)
kKeyIcon.Position = UDim2.new(0, 8, 0, 0)
kKeyIcon.BackgroundTransparency = 1
kKeyIcon.Text = "🔑"
kKeyIcon.TextSize = 16
kKeyIcon.Parent = kInputBg

local kInput = Instance.new("TextBox")
kInput.Size = UDim2.new(1, -46, 1, 0)
kInput.Position = UDim2.new(0, 42, 0, 0)
kInput.BackgroundTransparency = 1
kInput.Text = ""
kInput.PlaceholderText = "請輸入金鑰…"
kInput.PlaceholderColor3 = rgb(100,100,120)
kInput.TextColor3 = rgb(240,244,252)
kInput.Font = Enum.Font.Code
kInput.TextSize = 15
kInput.TextXAlignment = Enum.TextXAlignment.Left
kInput.ClearTextOnFocus = false
kInput.Parent = kInputBg

local kSubmit = Instance.new("TextButton")
kSubmit.Size = UDim2.new(1, -50, 0, 44)
kSubmit.Position = UDim2.new(0, 25, 0, 216)
kSubmit.BackgroundColor3 = rgb(140,0,255)
kSubmit.BorderSizePixel = 0
kSubmit.Text = "🚀 驗證並解鎖"
kSubmit.Font = Enum.Font.GothamBold
kSubmit.TextSize = 14
kSubmit.TextColor3 = rgb(255,255,255)
kSubmit.AutoButtonColor = false
kSubmit.Parent = kCard
corner(kSubmit, 12)
local kSubmitGrad = Instance.new("UIGradient")
kSubmitGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, rgb(140,0,255)),
	ColorSequenceKeypoint.new(1, rgb(80,0,200)),
})
kSubmitGrad.Parent = kSubmit
kSubmit.MouseEnter:Connect(function() tw(kSubmit, {Size = UDim2.new(1,-46,0,44), Position = UDim2.new(0,23,0,216)}, 0.12) end)
kSubmit.MouseLeave:Connect(function() tw(kSubmit, {Size = UDim2.new(1,-50,0,44), Position = UDim2.new(0,25,0,216)}, 0.12) end)

local kStatus = Instance.new("TextLabel")
kStatus.Size = UDim2.new(1, -50, 0, 16)
kStatus.Position = UDim2.new(0, 25, 0, 266)
kStatus.BackgroundTransparency = 1
kStatus.Text = ""
kStatus.Font = Enum.Font.GothamMedium
kStatus.TextSize = 11
kStatus.Parent = kCard

local kAnimRunning = true
task.spawn(function()
	local rot = 0
	while kAnimRunning and kDim.Parent do
		rot = (rot + 0.6) % 360
		kBgGrad.Rotation = rot
		kStripGrad.Offset = Vector2.new((math.sin(tick()) * 0.5), 0)
		task.wait(0.03)
	end
end)

local passed = false
local function tryAuth()
	if kInput.Text == VALID_KEY then
		passed = true
		kStatus.TextColor3 = rgb(120,255,180)
		kStatus.Text = "✅ 驗證成功"
		kInputStroke.Color = rgb(120,255,180)
		kCardStroke.Color = rgb(120,255,180)
		task.wait(0.5)
		tw(kDim, {BackgroundTransparency = 1}, 0.4)
		tw(kGradFrame, {BackgroundTransparency = 1}, 0.4)
		tw(kCard, {BackgroundTransparency = 1, Size = UDim2.new(0,420,0,240), Position = UDim2.new(0.5,-210,0.5,-120)}, 0.4)
		for _, d in ipairs(kDim:GetDescendants()) do
			if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then tw(d, {TextTransparency=1}, 0.35) end
			if d:IsA("Frame") then tw(d, {BackgroundTransparency=1}, 0.35) end
			if d:IsA("UIStroke") then tw(d, {Transparency=1}, 0.35) end
		end
		task.wait(0.45)
		kAnimRunning = false
		keyGui:Destroy()
	else
		kStatus.TextColor3 = rgb(255,110,130)
		kStatus.Text = "❌ 金鑰無效"
		kInputStroke.Color = rgb(255,110,130)
		kInput.Text = ""
		local orig = kCard.Position
		for i = 1, 5 do
			kCard.Position = orig + UDim2.new(0, i%2==0 and 8 or -8, 0, 0)
			task.wait(0.03)
		end
		kCard.Position = orig
		task.delay(1.5, function()
			if kStatus.Parent then kStatus.Text=""; kInputStroke.Color=rgb(60,60,80) end
		end)
	end
end
kSubmit.MouseButton1Click:Connect(tryAuth)
kInput.FocusLost:Connect(function(e) if e then tryAuth() end end)
repeat task.wait(0.1) until passed

-- ═══════════════════════════════════════
-- HUB PRINCIPAL
-- ═══════════════════════════════════════
local Hub = {conns={}, draws={}, renders={}, esps={}, hls={}, tabs={}, active=nil, anim=true}
shared._4VJShopRivals = Hub

function Hub:cleanup()
	Hub.anim = false
	for _,c in pairs(self.conns) do pcall(function() c:Disconnect() end) end
	for _,n in pairs(self.renders) do pcall(function() RunService:UnbindFromRenderStep(n) end) end
	for _,os in pairs(self.esps) do for _,o in pairs(os) do pcall(function() o:Remove() end) end end
	for _,h in pairs(self.hls) do pcall(function() h:Destroy() end) end
	for _,d in pairs(self.draws) do pcall(function() d:Remove() end) end
	if self.gui then self.gui:Destroy() end
	shared._4VJShopRivals = nil
end
function Hub:notify(t,d)
	pcall(function() StarterGui:SetCore("SendNotification", {Title="💎 4VJ SHOP", Text=t, Duration=d or 3}) end)
end

Hub.gui = Instance.new("ScreenGui")
Hub.gui.Name = "4VJShopGUI"
Hub.gui.ResetOnSpawn = false
Hub.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
Hub.gui.DisplayOrder = 998
Hub.gui.IgnoreGuiInset = true
pcall(function() Hub.gui.Parent = CoreGui end)
if not Hub.gui.Parent then Hub.gui.Parent = LP:WaitForChild("PlayerGui") end

-- Fenêtre principale
Hub.win = Instance.new("Frame")
Hub.win.Size = UDim2.new(0, 800, 0, 480)
Hub.win.Position = UDim2.new(0.5, -400, 0.5, -240)
Hub.win.BackgroundColor3 = P.bg
Hub.win.BackgroundTransparency = 0.02
Hub.win.BorderSizePixel = 0
Hub.win.ClipsDescendants = true
Hub.win.Parent = Hub.gui
corner(Hub.win, 14)
local winStroke = stroke(Hub.win, P.accent, 1)

-- Fond animé (orbs)
local bgLayer = Instance.new("Frame")
bgLayer.Size = UDim2.new(1,0,1,0)
bgLayer.BackgroundColor3 = P.bg
bgLayer.BorderSizePixel = 0
bgLayer.ZIndex = 0
bgLayer.Parent = Hub.win
local orbs = {}
for i = 1, 3 do
	local orb = Instance.new("Frame")
	orb.Size = UDim2.new(0, 280, 0, 280)
	orb.Position = UDim2.new(math.random(), 0, math.random(), 0)
	orb.BackgroundColor3 = i == 1 and P.g1 or (i == 2 and P.g2 or P.g3)
	orb.BackgroundTransparency = 0.9
	orb.BorderSizePixel = 0
	orb.ZIndex = 0
	orb.Parent = bgLayer
	corner(orb, 140)
	orbs[i] = {obj=orb, ox=math.random()*0.8, oy=math.random()*0.8, sp=math.random(3,8)/100, ph=math.random()*6.28}
end
task.spawn(function()
	while Hub.anim and Hub.win.Parent do
		local t = tick()
		for i, o in ipairs(orbs) do
			if o.obj.Parent then
				local x = o.ox + math.sin(t * o.sp + o.ph) * 0.15
				local y = o.oy + math.cos(t * o.sp * 0.7 + o.ph) * 0.15
				o.obj.Position = UDim2.new(x, 0, y, 0)
			end
		end
		task.wait(0.03)
	end
end)

-- Top bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 48)
topBar.BackgroundColor3 = P.panel
topBar.BackgroundTransparency = 0.15
topBar.BorderSizePixel = 0
topBar.ZIndex = 2
topBar.Parent = Hub.win

local topAccent = Instance.new("Frame")
topAccent.Size = UDim2.new(1, 0, 0, 2)
topAccent.Position = UDim2.new(0, 0, 1, -2)
topAccent.BackgroundColor3 = P.accent
topAccent.BorderSizePixel = 0
topAccent.ZIndex = 3
topAccent.Parent = topBar
local topAccentGrad = Instance.new("UIGradient")
topAccentGrad.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, P.g1),
	ColorSequenceKeypoint.new(0.5, P.g2),
	ColorSequenceKeypoint.new(1, P.g3),
})
topAccentGrad.Parent = topAccent

local logoBox = Instance.new("Frame")
logoBox.Size = UDim2.new(0, 32, 0, 32)
logoBox.Position = UDim2.new(0, 14, 0.5, -16)
logoBox.BackgroundColor3 = P.accent
logoBox.BackgroundTransparency = 0.85
logoBox.BorderSizePixel = 0
logoBox.ZIndex = 3
logoBox.Parent = topBar
corner(logoBox, 9)
local logo = Instance.new("TextLabel")
logo.Size = UDim2.new(1,0,1,0); logo.BackgroundTransparency = 1
logo.Text = "💎"; logo.Font = Enum.Font.GothamBold
logo.TextSize = 20; logo.TextColor3 = P.accent; logo.ZIndex = 3
logo.Parent = logoBox

local wordmark = Instance.new("TextLabel")
wordmark.Size = UDim2.new(0, 150, 1, 0)
wordmark.Position = UDim2.new(0, 54, 0, 0)
wordmark.BackgroundTransparency = 1
wordmark.Text = "4VJ SHOP"
wordmark.Font = Enum.Font.GothamBlack
wordmark.TextSize = 17
wordmark.TextColor3 = P.text
wordmark.TextXAlignment = Enum.TextXAlignment.Left
wordmark.ZIndex = 3
wordmark.Parent = topBar

local verPill = Instance.new("TextLabel")
verPill.Size = UDim2.new(0, 50, 0, 16)
verPill.Position = UDim2.new(0, 176, 0.5, -8)
verPill.BackgroundColor3 = P.accent
verPill.BackgroundTransparency = 0.82
verPill.Text = "v1 paid"
verPill.Font = Enum.Font.GothamBold
verPill.TextSize = 9
verPill.TextColor3 = P.accent
verPill.ZIndex = 3
verPill.Parent = topBar
corner(verPill, 8)

-- Barre de recherche
local searchWrap = Instance.new("Frame")
searchWrap.Size = UDim2.new(0, 250, 0, 30)
searchWrap.Position = UDim2.new(0.5, -125, 0.5, -15)
searchWrap.BackgroundColor3 = P.bg
searchWrap.BackgroundTransparency = 0.2
searchWrap.BorderSizePixel = 0
searchWrap.ZIndex = 3
searchWrap.Parent = topBar
corner(searchWrap, 9)
stroke(searchWrap, P.border, 1)
local searchIcon = Instance.new("TextLabel")
searchIcon.Size = UDim2.new(0,26,1,0); searchIcon.Position = UDim2.new(0,6,0,0)
searchIcon.BackgroundTransparency = 1; searchIcon.Text = "🔍"
searchIcon.TextSize = 12; searchIcon.ZIndex = 3; searchIcon.Parent = searchWrap
local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1,-36,1,0); searchBox.Position = UDim2.new(0,32,0,0)
searchBox.BackgroundTransparency = 1; searchBox.PlaceholderText = "搜尋…"
searchBox.PlaceholderColor3 = P.dim; searchBox.Text = ""
searchBox.TextColor3 = P.text; searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 11; searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false; searchBox.ZIndex = 3; searchBox.Parent = searchWrap

-- Boutons langue / min / close
local langBtn = Instance.new("TextButton")
langBtn.Size = UDim2.new(0, 48, 0, 26)
langBtn.Position = UDim2.new(1, -140, 0.5, -13)
langBtn.BackgroundColor3 = P.card
langBtn.Text = "🇹🇼 繁體中文"
langBtn.Font = Enum.Font.GothamBold
langBtn.TextSize = 10
langBtn.TextColor3 = P.text
langBtn.BorderSizePixel = 0
langBtn.AutoButtonColor = false
langBtn.ZIndex = 3
langBtn.Parent = topBar
corner(langBtn, 7); stroke(langBtn, P.border, 1)

local minBtn = Instance.new("TextButton")
minBtn.Size = UDim2.new(0, 28, 0, 26)
minBtn.Position = UDim2.new(1, -84, 0.5, -13)
minBtn.BackgroundColor3 = P.card
minBtn.Text = "➖"
minBtn.Font = Enum.Font.GothamBold
minBtn.TextSize = 10
minBtn.TextColor3 = P.dim
minBtn.BorderSizePixel = 0
minBtn.AutoButtonColor = false
minBtn.ZIndex = 3
minBtn.Parent = topBar
corner(minBtn, 7)

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 28, 0, 26)
closeBtn.Position = UDim2.new(1, -48, 0.5, -13)
closeBtn.BackgroundColor3 = P.bad
closeBtn.BackgroundTransparency = 0.85
closeBtn.Text = "✖️"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 10
closeBtn.TextColor3 = P.bad
closeBtn.BorderSizePixel = 0
closeBtn.AutoButtonColor = false
closeBtn.ZIndex = 3
closeBtn.Parent = topBar
corner(closeBtn, 7)
closeBtn.MouseButton1Click:Connect(function() Hub:cleanup() end)

-- Drag
do
	local dragging, dragStart, startPos
	topBar.InputBegan:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
			dragging=true; dragStart=i.Position; startPos=Hub.win.Position
		end
	end)
	topBar.InputEnded:Connect(function(i)
		if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
	end)
	UserInput.InputChanged:Connect(function(i)
		if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
			local d=i.Position-dragStart
			Hub.win.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
		end
	end)
end

-- Navigation
local navBar = Instance.new("Frame")
navBar.Size = UDim2.new(1, 0, 0, 44)
navBar.Position = UDim2.new(0, 0, 0, 48)
navBar.BackgroundColor3 = P.panel
navBar.BackgroundTransparency = 0.5
navBar.BorderSizePixel = 0
navBar.ZIndex = 2
navBar.Parent = Hub.win
local navLine = Instance.new("Frame")
navLine.Size = UDim2.new(1,0,0,1); navLine.Position = UDim2.new(0,0,1,-1)
navLine.BackgroundColor3 = P.border; navLine.BorderSizePixel = 0; navLine.ZIndex = 2; navLine.Parent = navBar
local navScroll = Instance.new("ScrollingFrame")
navScroll.Size = UDim2.new(1, -20, 1, 0); navScroll.Position = UDim2.new(0, 10, 0, 0)
navScroll.BackgroundTransparency = 1; navScroll.BorderSizePixel = 0
navScroll.ScrollBarThickness = 0; navScroll.ScrollingDirection = Enum.ScrollingDirection.X
navScroll.CanvasSize = UDim2.new(0,0,1,0); navScroll.AutomaticCanvasSize = Enum.AutomaticSize.X
navScroll.ZIndex = 2; navScroll.Parent = navBar
local navLayout = Instance.new("UIListLayout")
navLayout.FillDirection = Enum.FillDirection.Horizontal
navLayout.Padding = UDim.new(0, 6)
navLayout.VerticalAlignment = Enum.VerticalAlignment.Center
navLayout.Parent = navScroll

-- Contenu + Stats
local content = Instance.new("Frame")
content.Size = UDim2.new(1, -230, 1, -122)
content.Position = UDim2.new(0, 0, 0, 92)
content.BackgroundTransparency = 1
content.ZIndex = 2
content.Parent = Hub.win

local statsPanel = Instance.new("Frame")
statsPanel.Size = UDim2.new(0, 230, 1, -92)
statsPanel.Position = UDim2.new(1, -230, 0, 92)
statsPanel.BackgroundColor3 = P.panel
statsPanel.BackgroundTransparency = 0.35
statsPanel.BorderSizePixel = 0
statsPanel.ZIndex = 2
statsPanel.Parent = Hub.win
local statsLine = Instance.new("Frame")
statsLine.Size = UDim2.new(0,1,1,0); statsLine.BackgroundColor3 = P.border
statsLine.BorderSizePixel = 0; statsLine.ZIndex = 2; statsLine.Parent = statsPanel

-- Bottom strip
local bottomStrip = Instance.new("Frame")
bottomStrip.Size = UDim2.new(1, 0, 0, 30)
bottomStrip.Position = UDim2.new(0, 0, 1, -30)
bottomStrip.BackgroundColor3 = P.panel
bottomStrip.BackgroundTransparency = 0.15
bottomStrip.BorderSizePixel = 0
bottomStrip.ZIndex = 3
bottomStrip.Parent = Hub.win
local bottomLine = Instance.new("Frame")
bottomLine.Size = UDim2.new(1,0,0,1); bottomLine.BackgroundColor3 = P.border
bottomLine.BorderSizePixel = 0; bottomLine.ZIndex = 3; bottomLine.Parent = bottomStrip
local hintText = Instance.new("TextLabel")
hintText.Size = UDim2.new(1, -20, 1, 0); hintText.Position = UDim2.new(0, 12, 0, 0)
hintText.BackgroundTransparency = 1
hintText.Text = "⌨️ RightCtrl: Menu · 🎯 L: Aim · 🔇 K: Silent · 📡 P: ESP · ✈️ F: Fly · 👻 V: Noclip · ⚡ G: Speed"
hintText.Font = Enum.Font.GothamMedium
hintText.TextSize = 10
hintText.TextColor3 = P.dim
hintText.TextXAlignment = Enum.TextXAlignment.Left
hintText.ZIndex = 3
hintText.Parent = bottomStrip

local isMin = false
minBtn.MouseButton1Click:Connect(function()
	isMin = not isMin
	tw(Hub.win, {Size = isMin and UDim2.new(0,800,0,48) or UDim2.new(0,800,0,480)}, 0.25)
end)

local guiVisible = true
table.insert(Hub.conns, UserInput.InputBegan:Connect(function(i, gpe)
	if gpe then return end
	if i.KeyCode == Enum.KeyCode.RightControl then
		guiVisible = not guiVisible
		Hub.gui.Enabled = guiVisible
	end
end))

-- ═══════════════════════════════════════
-- STATS PANEL
-- ═══════════════════════════════════════
local function statsHead(y, txt)
	local h = Instance.new("TextLabel")
	h.Size = UDim2.new(1,-24,0,14); h.Position = UDim2.new(0,14,0,y)
	h.BackgroundTransparency = 1; h.Text = txt
	h.Font = Enum.Font.GothamBold; h.TextSize = 10
	h.TextColor3 = P.accent; h.TextXAlignment = Enum.TextXAlignment.Left
	h.ZIndex = 3; h.Parent = statsPanel
	h:SetAttribute("en", txt:gsub("📊 LIVE STATS","LIVE STATS"):gsub("⚡ ACTIONS RAPIDES","QUICK ACTIONS"))
end

local function statsRow(y, icon, label)
	local row = Instance.new("Frame")
	row.Size = UDim2.new(1,-24,0,26); row.Position = UDim2.new(0,12,0,y)
	row.BackgroundColor3 = P.card; row.BackgroundTransparency = 0.35
	row.BorderSizePixel = 0; row.ZIndex = 3; row.Parent = statsPanel
	corner(row, 7)
	local ic = Instance.new("TextLabel")
	ic.Size = UDim2.new(0,20,1,0); ic.Position = UDim2.new(0,8,0,0)
	ic.BackgroundTransparency = 1; ic.Text = icon; ic.TextSize = 12; ic.ZIndex = 3; ic.Parent = row
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5,0,1,0); lbl.Position = UDim2.new(0,30,0,0)
	lbl.BackgroundTransparency = 1; lbl.Text = label
	lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 10
	lbl.TextColor3 = P.dim; lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.ZIndex = 3; lbl.Parent = row
	lbl:SetAttribute("en", label)
	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0.45,-8,1,0); val.Position = UDim2.new(0.55,0,0,0)
	val.BackgroundTransparency = 1; val.Text = "—"
	val.Font = Enum.Font.Code; val.TextSize = 11
	val.TextColor3 = P.text; val.TextXAlignment = Enum.TextXAlignment.Right
	val.ZIndex = 3; val.Parent = row
	pad(val, 0, 0, 0, 8)
	return val
end

local function statsBtn(y, icon, txt, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,-24,0,28); b.Position = UDim2.new(0,12,0,y)
	b.BackgroundColor3 = P.accent; b.BackgroundTransparency = 0.84
	b.Text = icon.." "..txt
	b.Font = Enum.Font.GothamBold; b.TextSize = 10; b.TextColor3 = P.accent
	b.AutoButtonColor = false; b.BorderSizePixel = 0; b.ZIndex = 3; b.Parent = statsPanel
	corner(b, 7); stroke(b, P.accent, 1)
	b:SetAttribute("en", txt)
	b.MouseEnter:Connect(function() tw(b, {BackgroundTransparency=0.5}, 0.12); b.TextColor3 = P.text end)
	b.MouseLeave:Connect(function() tw(b, {BackgroundTransparency=0.84}, 0.12); b.TextColor3 = P.accent end)
	b.MouseButton1Click:Connect(cb or function() end)
	return b
end

statsHead(14, "📊 LIVE STATS")
local sFPS   = statsRow(32,  "🖥️", "FPS")
local sPing  = statsRow(62,  "📶", "Ping")
local sPlay  = statsRow(92,  "👥", "Joueurs")
local sTeam  = statsRow(122, "🚩", "Team")
local sHP    = statsRow(152, "❤️", "Santé")
statsHead(190, "⚡ ACTIONS RAPIDES")
statsBtn(208, "🔄", "Rejoin", function()
	TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP)
end)
statsBtn(242, "🌐", "Server Hop", function()
	pcall(function()
		local u = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100"
		local r = request({Url=u,Method="GET"})
		local d = HttpService:JSONDecode(r.Body)
		if d and d.data then
			for _,s in ipairs(d.data) do
				if s.playing < s.maxPlayers and s.id ~= game.JobId then
					TeleportService:TeleportToPlaceInstance(game.PlaceId, s.id, LP); return
				end
			end
		end
	end)
end)
statsBtn(276, "📋", "Copy Server ID", function()
	pcall(setclipboard, game.JobId); Hub:notify("📋 Server ID copié")
end)
statsBtn(310, "🚀", "FPS Boost", function()
	settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
	for _,v in ipairs(workspace:GetDescendants()) do
		if v:IsA("Decal") or v:IsA("Texture") then v.Transparency=1
		elseif v:IsA("ParticleEmitter") or v:IsA("Trail") then v.Enabled=false end
	end
	for _,v in ipairs(Lighting:GetDescendants()) do if v:IsA("PostEffect") then v.Enabled=false end end
	Hub:notify("🚀 FPS Boost appliqué")
end)

-- ═══════════════════════════════════════
-- SYSTÈME DE TABS
-- ═══════════════════════════════════════
local pages = {}
local tabButtons = {}

function Hub:setTab(name)
	Hub.active = name
	for id, btn in pairs(tabButtons) do
		local a = id == name
		tw(btn, {BackgroundTransparency = a and 0.72 or 1}, 0.15)
		btn.TextColor3 = a and P.accent or P.dim
		local u = btn:FindFirstChild("U")
		if u then tw(u, {BackgroundTransparency = a and 0 or 1}, 0.15) end
	end
	for id, pg in pairs(pages) do pg.Visible = id == name end
end

function Hub:addTab(id, label, icon)
	local btn = Instance.new("TextButton")
	btn.Name = id; btn.Size = UDim2.new(0,0,0,32)
	btn.AutomaticSize = Enum.AutomaticSize.X
	btn.BackgroundColor3 = P.accent; btn.BackgroundTransparency = 1
	btn.Text = icon.." "..label
	btn:SetAttribute("en", label)
	btn:SetAttribute("icon", icon)
	btn.Font = Enum.Font.GothamBold; btn.TextSize = 11
	btn.TextColor3 = P.dim; btn.AutoButtonColor = false
	btn.BorderSizePixel = 0; btn.ZIndex = 2; btn.Parent = navScroll
	corner(btn, 9); pad(btn, 0, 0, 14, 14)
	local u = Instance.new("Frame")
	u.Name = "U"; u.Size = UDim2.new(0.55,0,0,2); u.Position = UDim2.new(0.225,0,1,-3)
	u.BackgroundColor3 = P.accent; u.BackgroundTransparency = 1
	u.BorderSizePixel = 0; u.ZIndex = 2; u.Parent = btn
	corner(u, 2)
	local page = Instance.new("ScrollingFrame")
	page.Name = id; page.Size = UDim2.new(1,-10,1,-8); page.Position = UDim2.new(0,10,0,4)
	page.BackgroundTransparency = 1; page.BorderSizePixel = 0
	page.ScrollBarThickness = 3; page.ScrollBarImageColor3 = P.accent
	page.CanvasSize = UDim2.new(0,0,0,0); page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	page.Visible = false; page.ZIndex = 2; page.Parent = content
	local l = Instance.new("UIListLayout"); l.Padding = UDim.new(0,6); l.Parent = page
	pad(page, 4, 10, 4, 6)
	tabButtons[id] = btn; pages[id] = page
	btn.MouseButton1Click:Connect(function() Hub:setTab(id) end)
	btn.MouseEnter:Connect(function() if Hub.active ~= id then tw(btn, {BackgroundTransparency=0.9}, 0.12) end end)
	btn.MouseLeave:Connect(function() if Hub.active ~= id then tw(btn, {BackgroundTransparency=1}, 0.12) end end)
	if not Hub.active then Hub:setTab(id) end
	return page
end

-- ═══════════════════════════════════════
-- COMPOSANTS GUI (corrigés)
-- ═══════════════════════════════════════
local function card(page, h, icon)
	local c = Instance.new("Frame")
	c.Size = UDim2.new(1,0,0,h or 36); c.BackgroundColor3 = P.card
	c.BackgroundTransparency = 0.1; c.BorderSizePixel = 0; c.ZIndex = 2; c.Parent = page
	corner(c, 9)
	local lblX = 12
	if icon then
		local ic = Instance.new("TextLabel")
		ic.Size = UDim2.new(0,22,1,0); ic.Position = UDim2.new(0,12,0,0)
		ic.BackgroundTransparency = 1; ic.Text = icon; ic.TextSize = 14; ic.ZIndex = 2; ic.Parent = c
		lblX = 36
	end
	c.MouseEnter:Connect(function() tw(c, {BackgroundColor3=P.cardH}, 0.1) end)
	c.MouseLeave:Connect(function() tw(c, {BackgroundColor3=P.card}, 0.1) end)
	return c, lblX
end

function Hub:section(page, txt, icon)
	local h = Instance.new("Frame")
	h.Size = UDim2.new(1,0,0,22); h.BackgroundTransparency = 1; h.ZIndex = 2; h.Parent = page
	local line = Instance.new("Frame")
	line.Size = UDim2.new(0,3,0,12); line.Position = UDim2.new(0,2,0.5,-6)
	line.BackgroundColor3 = P.accent; line.BorderSizePixel = 0; line.ZIndex = 2; line.Parent = h
	corner(line, 2)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,-20,1,0); lbl.Position = UDim2.new(0,12,0,0)
	lbl.BackgroundTransparency = 1; lbl.Text = (icon and (icon.." ") or "")..txt:upper()
	lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 10
	lbl.TextColor3 = P.dim; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 2; lbl.Parent = h
	lbl:SetAttribute("en", txt:upper())
	lbl:SetAttribute("icon", icon or "")
end

function Hub:toggle(page, label, default, cb, icon)
	local c, lblX = card(page, 36, icon)
	local state = default
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,-70-lblX,1,0); lbl.Position = UDim2.new(0,lblX,0,0)
	lbl.BackgroundTransparency = 1; lbl.Text = tr(label); lbl:SetAttribute("en", label)
	lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12
	lbl.TextColor3 = P.text; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 2; lbl.Parent = c
	local tBg = Instance.new("Frame")
	tBg.Size = UDim2.new(0,38,0,20); tBg.Position = UDim2.new(1,-50,0.5,-10)
	tBg.BackgroundColor3 = state and P.accent or rgb(48,54,66)
	tBg.BorderSizePixel = 0; tBg.ZIndex = 2; tBg.Parent = c
	corner(tBg, 10)
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0,14,0,14); dot.Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
	dot.BackgroundColor3 = state and rgb(11,13,20) or rgb(140,145,160)
	dot.BorderSizePixel = 0; dot.ZIndex = 2; dot.Parent = tBg
	corner(dot, 7)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,0,1,0); b.BackgroundTransparency = 1; b.Text = ""; b.ZIndex = 2; b.Parent = c
	b.MouseButton1Click:Connect(function()
		state = not state
		tw(tBg, {BackgroundColor3 = state and P.accent or rgb(48,54,66)}, 0.15)
		tw(dot, {Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),
			BackgroundColor3 = state and rgb(11,13,20) or rgb(140,145,160)}, 0.15)
		if cb then cb(state) end
	end)
	return {get=function() return state end}
end

function Hub:slider(page, label, min, max, default, cb, icon)
	local c, lblX = card(page, 50, icon)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,-70-lblX,0,20); lbl.Position = UDim2.new(0,lblX,0,4)
	lbl.BackgroundTransparency = 1; lbl.Text = tr(label); lbl:SetAttribute("en", label)
	lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12
	lbl.TextColor3 = P.text; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 2; lbl.Parent = c
	local val = Instance.new("TextLabel")
	val.Size = UDim2.new(0,50,0,20); val.Position = UDim2.new(1,-58,0,4)
	val.BackgroundTransparency = 1; val.Text = tostring(default); val.Font = Enum.Font.Code
	val.TextSize = 12; val.TextColor3 = P.accent; val.TextXAlignment = Enum.TextXAlignment.Right
	val.ZIndex = 2; val.Parent = c
	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1,-(lblX+22),0,4); bg.Position = UDim2.new(0,lblX,0,32)
	bg.BackgroundColor3 = rgb(48,54,66); bg.BorderSizePixel = 0; bg.ZIndex = 2; bg.Parent = c
	corner(bg, 2)
	local pct = (default-min)/math.max(max-min,1)
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(pct,0,1,0); fill.BackgroundColor3 = P.accent
	fill.BorderSizePixel = 0; fill.ZIndex = 2; fill.Parent = bg
	corner(fill, 2)
	local fg = Instance.new("UIGradient")
	fg.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,P.g1),ColorSequenceKeypoint.new(1,P.g2)})
	fg.Parent = fill
	local knob = Instance.new("Frame")
	knob.Size = UDim2.new(0,12,0,12); knob.Position = UDim2.new(pct,-6,0.5,-6)
	knob.BackgroundColor3 = P.accent; knob.BorderSizePixel = 0; knob.ZIndex = 2; knob.Parent = bg
	corner(knob, 6)
	local sliding = false
	local slBtn = Instance.new("TextButton")
	slBtn.Size = UDim2.new(1,0,0,20); slBtn.Position = UDim2.new(0,0,0,24)
	slBtn.BackgroundTransparency = 1; slBtn.Text = ""; slBtn.ZIndex = 2; slBtn.Parent = c
	slBtn.MouseButton1Down:Connect(function() sliding = true end)
	table.insert(Hub.conns, UserInput.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then sliding = false end
	end))
	table.insert(Hub.conns, UserInput.InputChanged:Connect(function(i)
		if sliding and i.UserInputType == Enum.UserInputType.MouseMovement then
			local ap = bg.AbsolutePosition.X
			local as = bg.AbsoluteSize.X
			local p2 = math.clamp((i.Position.X-ap)/as, 0, 1)
			local v = math.floor(min + (max-min)*p2)
			val.Text = tostring(v); fill.Size = UDim2.new(p2,0,1,0); knob.Position = UDim2.new(p2,-6,0.5,-6)
			if cb then cb(v) end
		end
	end))
end

function Hub:dropdown(page, label, options, default, cb, icon)
	local c, lblX = card(page, 36, icon)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(0.5,-lblX,1,0); lbl.Position = UDim2.new(0,lblX,0,0)
	lbl.BackgroundTransparency = 1; lbl.Text = tr(label); lbl:SetAttribute("en", label)
	lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12
	lbl.TextColor3 = P.text; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 2; lbl.Parent = c
	local sel = Instance.new("TextButton")
	sel.Size = UDim2.new(0.42,-10,0,22); sel.Position = UDim2.new(0.58,0,0.5,-11)
	sel.BackgroundColor3 = P.bg; sel.Text = " "..tr(default or options[1]).." ▾"
	sel.Font = Enum.Font.GothamMedium; sel.TextSize = 11; sel.TextColor3 = P.accent
	sel.BorderSizePixel = 0; sel.AutoButtonColor = false; sel.ZIndex = 2; sel.Parent = c
	corner(sel, 6); stroke(sel, P.border, 1)
	local list = Instance.new("Frame")
	list.Size = UDim2.new(0.42,-10,0,#options*24); list.Position = UDim2.new(0.58,0,1,2)
	list.BackgroundColor3 = P.card; list.BorderSizePixel = 0; list.Visible = false
	list.ZIndex = 40; list.Parent = c
	corner(list, 6); stroke(list, P.border, 1)
	local lay = Instance.new("UIListLayout"); lay.Parent = list
	for _, opt in ipairs(options) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1,0,0,24); b.BackgroundTransparency = 1
		b.Text = " "..tr(opt); b.Font = Enum.Font.GothamMedium; b.TextSize = 11
		b.TextColor3 = P.dim; b.TextXAlignment = Enum.TextXAlignment.Left; b.ZIndex = 41; b.Parent = list
		b.MouseButton1Click:Connect(function()
			sel.Text = " "..tr(opt).." ▾"; list.Visible = false
			if cb then cb(opt) end
		end)
		b.MouseEnter:Connect(function() b.TextColor3 = P.accent end)
		b.MouseLeave:Connect(function() b.TextColor3 = P.dim end)
	end
	local open = false
	sel.MouseButton1Click:Connect(function() open = not open; list.Visible = open end)
end

function Hub:button(page, label, cb, icon)
	local c, lblX = card(page, 36, icon)
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,-70-lblX,1,0); lbl.Position = UDim2.new(0,lblX,0,0)
	lbl.BackgroundTransparency = 1; lbl.Text = tr(label); lbl:SetAttribute("en", label)
	lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12
	lbl.TextColor3 = P.text; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 2; lbl.Parent = c
	local exec = Instance.new("TextButton")
	exec.Size = UDim2.new(0,52,0,22); exec.Position = UDim2.new(1,-62,0.5,-11)
	exec.BackgroundColor3 = P.accent; exec.BackgroundTransparency = 0.75
	exec.Text = "執行 ▸"; exec.Font = Enum.Font.GothamBold
	exec.TextSize = 9; exec.TextColor3 = P.accent
	exec.AutoButtonColor = false; exec.BorderSizePixel = 0; exec.ZIndex = 2; exec.Parent = c
	corner(exec, 6); stroke(exec, P.accent, 1)
	exec.MouseEnter:Connect(function() tw(exec, {BackgroundTransparency=0.3}, 0.1); exec.TextColor3 = P.bg end)
	exec.MouseLeave:Connect(function() tw(exec, {BackgroundTransparency=0.75}, 0.1); exec.TextColor3 = P.accent end)
	exec.MouseButton1Click:Connect(cb or function() end)
end

function Hub:keyToggle(page, label, default, defaultKey, cb, icon)
	local c, lblX = card(page, 36, icon)
	local state, currentKey, listening = default, defaultKey, false
	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1,-120-lblX,1,0); lbl.Position = UDim2.new(0,lblX,0,0)
	lbl.BackgroundTransparency = 1; lbl.Text = tr(label); lbl:SetAttribute("en", label)
	lbl.Font = Enum.Font.GothamMedium; lbl.TextSize = 12
	lbl.TextColor3 = P.text; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.ZIndex = 2; lbl.Parent = c
	local kb = Instance.new("TextButton")
	kb.Size = UDim2.new(0,42,0,20); kb.Position = UDim2.new(1,-100,0.5,-10)
	kb.BackgroundColor3 = P.bg; kb.Text = defaultKey and "["..defaultKey.Name.."]" or "[--]"
	kb.Font = Enum.Font.Code; kb.TextSize = 9; kb.TextColor3 = P.dim
	kb.BorderSizePixel = 0; kb.AutoButtonColor = false; kb.ZIndex = 2; kb.Parent = c
	corner(kb, 4); stroke(kb, P.border, 1)
	local tBg = Instance.new("Frame")
	tBg.Size = UDim2.new(0,38,0,20); tBg.Position = UDim2.new(1,-50,0.5,-10)
	tBg.BackgroundColor3 = state and P.accent or rgb(48,54,66)
	tBg.BorderSizePixel = 0; tBg.ZIndex = 2; tBg.Parent = c
	corner(tBg, 10)
	local dot = Instance.new("Frame")
	dot.Size = UDim2.new(0,14,0,14); dot.Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7)
	dot.BackgroundColor3 = state and rgb(11,13,20) or rgb(140,145,160)
	dot.BorderSizePixel = 0; dot.ZIndex = 2; dot.Parent = tBg
	corner(dot, 7)
	local clickBtn = Instance.new("TextButton")
	clickBtn.Size = UDim2.new(1,-110,1,0); clickBtn.BackgroundTransparency = 1
	clickBtn.Text = ""; clickBtn.ZIndex = 2; clickBtn.Parent = c
	local function set(ns)
		state = ns
		tw(tBg, {BackgroundColor3 = state and P.accent or rgb(48,54,66)}, 0.15)
		tw(dot, {Position = state and UDim2.new(1,-16,0.5,-7) or UDim2.new(0,2,0.5,-7),
			BackgroundColor3 = state and rgb(11,13,20) or rgb(140,145,160)}, 0.15)
		if cb then cb(state) end
	end
	clickBtn.MouseButton1Click:Connect(function() set(not state) end)
	kb.MouseButton1Click:Connect(function() listening=true; kb.Text="[...]"; kb.TextColor3=P.accent end)
	kb.MouseButton2Click:Connect(function() currentKey=nil; listening=false; kb.Text="[--]"; kb.TextColor3=P.dim end)
	table.insert(Hub.conns, UserInput.InputBegan:Connect(function(i, gpe)
		if i.UserInputType ~= Enum.UserInputType.Keyboard then return end
		if listening then
			if i.KeyCode == Enum.KeyCode.Period then currentKey=nil; kb.Text="[--]"
			elseif i.KeyCode == Enum.KeyCode.Escape then kb.Text = currentKey and ("["..currentKey.Name.."]") or "[--]"
			else currentKey=i.KeyCode; kb.Text="["..currentKey.Name.."]" end
			kb.TextColor3=P.dim; listening=false; return
		end
		if gpe then return end
		if currentKey and i.KeyCode == currentKey then set(not state) end
	end))
end

function Hub:label(page, txt)
	local h = Instance.new("Frame")
	h.Size = UDim2.new(1,0,0,16); h.BackgroundTransparency = 1; h.ZIndex = 2; h.Parent = page
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1,-8,1,0); l.Position = UDim2.new(0,8,0,0)
	l.BackgroundTransparency = 1; l.Text = txt; l.Font = Enum.Font.Gotham
	l.TextSize = 10; l.TextColor3 = P.dim; l.TextXAlignment = Enum.TextXAlignment.Left
	l.ZIndex = 2; l.Parent = h; l:SetAttribute("en", txt)
end

-- ═══════════════════════════════════════
-- CONSTRUCTION DES TABS
-- ═══════════════════════════════════════
local pgCombat = Hub:addTab("combat", tr("Combat"), "🎯")
local pgEsp    = Hub:addTab("esp", tr("ESP"), "📡")
local pgMove   = Hub:addTab("move", tr("Movement"), "🏃")
local pgVis    = Hub:addTab("vis", tr("Visuals"), "🎨")
local pgUnlock = Hub:addTab("unlock", tr("Unlock"), "🔓")
local pgMisc   = Hub:addTab("misc", tr("Misc"), "🧩")
local pgStyle  = Hub:addTab("style", tr("Style"), "🌈")

-- COMBAT
Hub:section(pgCombat, tr("Aimbot"), "🎯")
Hub:keyToggle(pgCombat, "Aimbot", false, Enum.KeyCode.L, function(v) S.aimbotOn=v end, "🎯")
Hub:dropdown(pgCombat, "Aim Mode", {"Hold RMB","Hold LMB","Always"}, "Hold RMB", function(v) S.aimMode=v end, "🖱️")
Hub:toggle(pgCombat, "Prediction", true, function(v) S.aimPred=v end, "🔮")
Hub:toggle(pgCombat, "Wall Check", false, function(v) S.aimWall=v end, "🧱")
Hub:toggle(pgCombat, "Team Check", true, function(v) S.aimTeam=v end, "🚩")
Hub:slider(pgCombat, "Smoothing", 1, 20, 3, function(v) S.aimSmooth=v end, "〰️")
Hub:dropdown(pgCombat, "Target Bone", {"Head","HumanoidRootPart","UpperTorso"}, "Head", function(v) S.aimBone=v end, "🦴")
Hub:dropdown(pgCombat, "Priority", {"Closest","LowestHP","Distance"}, "Closest", function(v) S.priority=v end, "🎚️")
Hub:section(pgCombat, tr("Silent Aim"), "🔇")
Hub:keyToggle(pgCombat, "Silent Aim", false, Enum.KeyCode.K, function(v) S.silentOn=v end, "🔇")
Hub:slider(pgCombat, "Hit Chance", 1, 100, 100, function(v) S.hitChance=v end, "🎲")
Hub:section(pgCombat, tr("Automation"), "⚡")
Hub:keyToggle(pgCombat, "Triggerbot", false, Enum.KeyCode.J, function(v) S.trigOn=v end, "⚡")
Hub:slider(pgCombat, "Trigger Delay (ms)", 0, 200, 50, function(v) S.trigDelay=v end, "⏱️")
Hub:keyToggle(pgCombat, "Auto Shoot", false, Enum.KeyCode.H, function(v) S.autoShoot=v end, "🔫")
Hub:toggle(pgCombat, "Aim Lock", false, function(v) S.aimLock=v end, "🔒")
Hub:toggle(pgCombat, "Auto Clicker", false, function(v) S.autoClick=v end, "🖱️")
Hub:slider(pgCombat, "Clicks / Sec", 1, 25, 12, function(v) S.cps=v end, "⚡")
Hub:section(pgCombat, tr("FOV"), "⭕")
Hub:toggle(pgCombat, "Show FOV Circle", false, function(v) S.fovShow=v end, "⭕")
Hub:slider(pgCombat, "FOV Radius", 50, 500, 200, function(v) S.fovRadius=v end, "📏")
Hub:dropdown(pgCombat, "FOV Color", {"Mint","Blue","Pink","White","Yellow"}, "Mint", function(v)
	local m = {Mint=rgb(120,255,214),Blue=rgb(120,160,255),Pink=rgb(255,120,220),White=rgb(255,255,255),Yellow=rgb(255,220,60)}
	S.fovColor = m[v] or rgb(120,255,214)
end, "🎨")

-- ESP
Hub:section(pgEsp, tr("Player ESP"), "📡")
Hub:keyToggle(pgEsp, "Enable ESP", false, Enum.KeyCode.P, function(v) S.espOn=v end, "📡")
Hub:toggle(pgEsp, "Boxes", true, function(v) S.espBox=v end, "🔲")
Hub:toggle(pgEsp, "Names", true, function(v) S.espName=v end, "🏷️")
Hub:toggle(pgEsp, "Health Bars", true, function(v) S.espHp=v end, "❤️")
Hub:toggle(pgEsp, "Distance", true, function(v) S.espDist=v end, "📏")
Hub:toggle(pgEsp, "Tracers", false, function(v) S.espTrace=v end, "📈")
Hub:toggle(pgEsp, "Head Dot", false, function(v) S.headDot=v end, "🔴")
Hub:toggle(pgEsp, "Snaplines", false, function(v) S.snaplines=v end, "📉")
Hub:toggle(pgEsp, "Off-Screen Arrows", false, function(v) S.arrows=v end, "➡️")
Hub:toggle(pgEsp, "Team Check", true, function(v) S.espTeam=v end, "🚩")
Hub:section(pgEsp, tr("Chams"), "🌈")
Hub:toggle(pgEsp, "Chams (Highlights)", false, function(v)
	S.chams=v
	if not v then for uid,h in pairs(Hub.hls) do h:Destroy(); Hub.hls[uid]=nil end end
end, "🌈")

-- MOVEMENT
Hub:section(pgMove, tr("Speed"), "⚡")
Hub:keyToggle(pgMove, "Speed Hack", false, Enum.KeyCode.G, function(v) S.speedOn=v end, "⚡")
Hub:slider(pgMove, "Walk Speed", 16, 150, 22, function(v) S.speedVal=v end, "🏃")
Hub:toggle(pgMove, "Auto Sprint", false, function(v) S.sprint=v end, "💨")
Hub:section(pgMove, tr("Fly"), "✈️")
Hub:keyToggle(pgMove, "Fly", false, Enum.KeyCode.F, function(v)
	S.flyOn=v
	if not v and LP.Character then
		local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
		if hrp then
			local bv=hrp:FindFirstChild("JFly_BV"); if bv then bv:Destroy() end
			local bg=hrp:FindFirstChild("JFly_BG"); if bg then bg:Destroy() end
		end
	end
end, "✈️")
Hub:slider(pgMove, "Fly Speed", 10, 300, 60, function(v) S.flySpd=v end, "🚀")
Hub:section(pgMove, tr("Physics"), "🌀")
Hub:keyToggle(pgMove, "Noclip", false, Enum.KeyCode.V, function(v) S.noclipOn=v end, "👻")
Hub:keyToggle(pgMove, "Infinite Jump", false, Enum.KeyCode.B, function(v) S.infJump=v end, "🦘")
Hub:toggle(pgMove, "Bunny Hop", false, function(v) S.bhop=v end, "🐰")
Hub:toggle(pgMove, "Long Jump", false, function(v) S.longJump=v end, "🦵")
Hub:slider(pgMove, "Long Jump Force", 20, 300, 80, function(v) S.longVal=v end, "💪")
Hub:toggle(pgMove, "TP to Mouse (Alt+Click)", false, function(v) S.tpMouse=v end, "📍")
Hub:toggle(pgMove, "Air Jump", false, function(v) S.airJump=v end, "🕊️")
Hub:toggle(pgMove, "Spider Climb", false, function(v) S.spider=v end, "🕷️")
Hub:toggle(pgMove, "Anti Fall Damage", false, function(v) S.antiFall=v end, "🪂")
Hub:section(pgMove, tr("Tweaks"), "🔧")
Hub:toggle(pgMove, "Custom Jump Power", false, function(v) S.jpOn=v end, "⬆️")
Hub:slider(pgMove, "Jump Power", 30, 200, 50, function(v) S.jpVal=v end, "💥")
Hub:toggle(pgMove, "Custom Gravity", false, function(v)
	S.gravOn=v; if not v then workspace.Gravity=196 end
end, "🌍")
Hub:slider(pgMove, "Gravity", 10, 196, 196, function(v) S.gravVal=v end, "🪐")
Hub:section(pgMove, tr("Freecam"), "🎥")
Hub:keyToggle(pgMove, "Freecam", false, Enum.KeyCode.C, function(v) S.freecam=v end, "🎥")
Hub:slider(pgMove, "Freecam Speed", 1, 10, 2, function(v) S.freecamSpd=v end, "🎬")

-- VISUALS
Hub:section(pgVis, tr("Lighting"), "💡")
Hub:toggle(pgVis, "Fullbright", false, function(v)
	S.fullbright=v
	if v then
		Lighting.Ambient=rgb(200,200,200); Lighting.Brightness=2; Lighting.GlobalShadows=false
		for _,fx in ipairs(Lighting:GetDescendants()) do
			if fx:IsA("ColorCorrectionEffect") or fx:IsA("BloomEffect") or fx:IsA("BlurEffect") then fx.Enabled=false end
		end
	else
		Lighting.Ambient=rgb(0,0,0); Lighting.Brightness=1; Lighting.GlobalShadows=true
		for _,fx in ipairs(Lighting:GetDescendants()) do
			if fx:IsA("ColorCorrectionEffect") or fx:IsA("BloomEffect") or fx:IsA("BlurEffect") then fx.Enabled=true end
		end
	end
end, "☀️")
Hub:toggle(pgVis, "No Fog", false, function(v) S.noFog=v end, "🌫️")
Hub:section(pgVis, tr("Camera"), "📷")
Hub:toggle(pgVis, "FOV Changer", false, function(v) S.camFov=v end, "🔭")
Hub:slider(pgVis, "Camera FOV", 30, 140, 100, function(v) S.camFovVal=v end, "📐")
Hub:toggle(pgVis, "Third Person", false, function(v) S.tps=v end, "🧍")
Hub:section(pgVis, tr("Crosshair"), "✚")
Hub:toggle(pgVis, "Custom Crosshair", false, function(v) S.xhair=v end, "✚")
Hub:slider(pgVis, "Size", 2, 20, 6, function(v) S.xhairSize=v end, "📏")
Hub:slider(pgVis, "Thickness", 1, 4, 1, function(v) S.xhairThick=v end, "✏️")
Hub:toggle(pgVis, "Hitmarker", false, function(v) S.hitmark=v end, "💢")
Hub:section(pgVis, tr("World"), "🌍")
Hub:toggle(pgVis, "Day/Night", false, function(v) S.ambient=v end, "🌗")
Hub:slider(pgVis, "Time of Day", 0, 24, 14, function(v) S.ambientTime=v end, "🕐")
Hub:toggle(pgVis, "No Textures", false, function(v)
	S.noTex=v
	if v then for _,d in ipairs(workspace:GetDescendants()) do
		if d:IsA("Decal") or d:IsA("Texture") then d.Transparency=1 end end end
end, "🎭")
Hub:toggle(pgVis, "No Kill Cam", false, function(v) S.noKillCam=v end, "📵")

-- UNLOCK (sans le bouton unlock weapons)
Hub:section(pgUnlock, tr("Cosmetics"), "🎁")
Hub:label(pgUnlock, " Débloque skins/wraps/charms dans le menu.")
Hub:button(pgUnlock, "Unlock All Cosmetics", function()
	Hub:notify("⏳ Chargement...")
	task.spawn(function()
		local ok, err = pcall(function()
			loadstring(game:HttpGet(
				"https://raw.githubusercontent.com/ScriptssForRoblox/RIVALS-Unlock-All-Skins/refs/heads/main/Rivals.lua"
			))()
			Hub:notify("✅ Cosmetics débloqués!")
		end)
		if not ok then Hub:notify("❌ "..tostring(err)) end
	end)
end, "🎨")
-- Le bouton "Unlock All Weapons" a été supprimé

-- MISC
Hub:section(pgMisc, tr("Utility"), "🛠️")
Hub:toggle(pgMisc, "Anti-AFK", true, function(v) S.afk=v end, "☕")
Hub:toggle(pgMisc, "Auto Respawn", false, function(v) S.autoRes=v end, "🔄")
Hub:toggle(pgMisc, "Instant Respawn", false, function(v) S.instRes=v end, "⚡")
Hub:toggle(pgMisc, "Spectate Alert", false, function(v) S.specAlert=v end, "👀")
Hub:section(pgMisc, tr("HUD"), "📺")
Hub:toggle(pgMisc, "FPS Counter", false, function(v) S.fpsHud=v end, "🖥️")
Hub:toggle(pgMisc, "Ping Counter", false, function(v) S.pingHud=v end, "📶")
Hub:toggle(pgMisc, "Watermark", true, function(v) S.watermark=v end, "💧")
Hub:section(pgMisc, tr("Queue"), "🎮")
Hub:button(pgMisc, "Auto Queue Unrated", function()
	local rem = ReplicatedStorage:FindFirstChild("Remotes")
	if rem then
		local m = rem:FindFirstChild("Misc")
		if m then local q = m:FindFirstChild("QueueJoin")
			if q then q:InvokeServer("Unrated"); Hub:notify("✅ En file!") end
		end
	end
end, "▶️")

-- STYLE (palettes)
Hub:section(pgStyle, tr("Palette"), "🎨")
local paletteNames = {"BlackPurple","Midnight","Neon","Royal"}
local paletteIcons = {BlackPurple="💎", Midnight="🌙", Neon="💚", Royal="👑"}
for _, name in ipairs(paletteNames) do
	Hub:button(pgStyle, name, function()
		if activePalette ~= name then
			activePalette = name
			P = setmetatable({}, {__index=function(_,k) return Palettes[activePalette][k] end})
			-- Mettre à jour les couleurs dynamiques (à faire, mais on rafraîchit le GUI)
			Hub:notify("🎨 Palette: "..name)
			-- On pourrait rafraîchir tout le GUI, mais on applique juste les nouvelles couleurs aux éléments existants
			-- Pour simplifier, on redéfinit les couleurs de base
			winStroke.Color = P.accent
			topAccent.BackgroundColor3 = P.accent
			topAccentGrad.Color = ColorSequence.new({ColorSequenceKeypoint.new(0,P.g1),ColorSequenceKeypoint.new(0.5,P.g2),ColorSequenceKeypoint.new(1,P.g3)})
			logoBox.BackgroundColor3 = P.accent
			logo.TextColor3 = P.accent
			verPill.BackgroundColor3 = P.accent
			verPill.TextColor3 = P.accent
			langBtn.BackgroundColor3 = P.card
			minBtn.BackgroundColor3 = P.card
			closeBtn.BackgroundColor3 = P.bad
			navBar.BackgroundColor3 = P.panel
			statsPanel.BackgroundColor3 = P.panel
			bottomStrip.BackgroundColor3 = P.panel
			hintText.TextColor3 = P.dim
			-- On pourrait aussi mettre à jour les couleurs des composants existants, mais on laisse la prochaine ouverture du GUI appliquer la nouvelle palette
		end
	end, paletteIcons[name])
end
Hub:section(pgStyle, tr("About"), "ℹ️")
Hub:label(pgStyle, " 💎 4VJ SHOP v1 paid")
Hub:label(pgStyle, " ⚔️ Rivals Hub · by Vcerd & JD")
Hub:label(pgStyle, " ⌨️ RightCtrl: Toggle Menu")

-- Bouton langue
langBtn.MouseButton1Click:Connect(function()
	local idx = 1
	for i, lang in ipairs(Languages) do
		if lang.code == activeLang then idx = i end
	end
	local nextIdx = idx % #Languages + 1
	activeLang = Languages[nextIdx].code
	langBtn.Text = Languages[nextIdx].flag.." "..Languages[nextIdx].name:upper()
	-- Mise à jour de tous les textes du GUI
	for _, inst in ipairs(Hub.gui:GetDescendants()) do
		if inst:IsA("TextLabel") or inst:IsA("TextButton") then
			local en = inst:GetAttribute("en")
			if en then
				local icon = inst:GetAttribute("icon") or ""
				local translated = tr(en)
				inst.Text = icon ~= "" and (icon.." "..translated) or translated
			end
		end
	end
	-- Mise à jour des onglets (titres)
	for id, btn in pairs(tabButtons) do
		local en = btn:GetAttribute("en")
		local icon = btn:GetAttribute("icon") or ""
		if en then
			btn.Text = icon.." "..tr(en)
		end
	end
	-- Mise à jour du watermark
	wmText.Text = "💎 4VJ SHOP · v1 paid"
end)

-- Barre de recherche
searchBox:GetPropertyChangedSignal("Text"):Connect(function()
	local q = searchBox.Text:lower()
	for _, pg in pairs(pages) do
		for _, child in ipairs(pg:GetChildren()) do
			if child:IsA("Frame") then
				if q == "" then child.Visible = true
				else
					local m = false
					for _, sub in ipairs(child:GetDescendants()) do
						if sub:IsA("TextLabel") and sub.Text:lower():find(q,1,true) then m=true; break end
					end
					child.Visible = m
				end
			end
		end
	end
end)

-- ═══════════════════════════════════════
-- LOGIQUES DE COMBAT (inchangées)
-- ═══════════════════════════════════════
local m1Down, m2Down = false, false
table.insert(Hub.conns, UserInput.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then m1Down = true
	elseif i.UserInputType == Enum.UserInputType.MouseButton2 then m2Down = true end
end))
table.insert(Hub.conns, UserInput.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then m1Down = false
	elseif i.UserInputType == Enum.UserInputType.MouseButton2 then m2Down = false end
end))

local function aimShould()
	if not S.aimbotOn then return false end
	if S.aimMode == "Always" then return true end
	if S.aimMode == "Hold LMB" then return m1Down end
	return m2Down
end

RunService:BindToRenderStep("JBT_Aimbot", Enum.RenderPriority.Camera.Value + 1, function()
	if not aimShould() then return end
	if not alive(LP) then return end
	local t, _, tp = closest()
	if not t or not tp then return end
	if S.aimPred then
		local c = t.Character
		local hrp = c and c:FindFirstChild("HumanoidRootPart")
		if hrp then
			local v = hrp.AssemblyLinearVelocity
			local r = (Cam.CFrame.Position - tp).Magnitude
			tp = tp + (v * (r/1500) * 0.5)
		end
	end
	local cf = Cam.CFrame
	local a = math.clamp(1 / math.max(S.aimSmooth,1), 0, 1)
	Cam.CFrame = cf:Lerp(CFrame.lookAt(cf.Position, tp), a)
end)
table.insert(Hub.renders, "JBT_Aimbot")

RunService:BindToRenderStep("JBT_AimLock", Enum.RenderPriority.Camera.Value + 2, function()
	if not S.aimLock or not alive(LP) then return end
	if not (m1Down or m2Down) then return end
	local t, _, tp = closest()
	if t and tp then Cam.CFrame = CFrame.lookAt(Cam.CFrame.Position, tp) end
end)
table.insert(Hub.renders, "JBT_AimLock")

local silentPos = nil
table.insert(Hub.conns, RunService.Heartbeat:Connect(function()
	if S.silentOn and alive(LP) then local _,_,tp = closest(); silentPos = tp else silentPos = nil end
end))

local oldNC
oldNC = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	if checkcaller() or not S.silentOn or not silentPos then return oldNC(self, ...) end
	if getnamecallmethod() == "Raycast" then
		local o, d = ...
		if typeof(o)=="Vector3" and typeof(d)=="Vector3" then
			local cp = Cam.CFrame.Position
			if (o-cp).Magnitude < 8 and d.Magnitude > 20 then
				if math.random(1,100) <= S.hitChance then
					return oldNC(self, o, (silentPos-o).Unit * d.Magnitude, select(3, ...))
				end
			end
		end
	end
	return oldNC(self, ...)
end))
pcall(function() if setstackhidden then setstackhidden(oldNC, true) end end)

local lastTrig = 0
table.insert(Hub.conns, RunService.Heartbeat:Connect(function()
	if not S.trigOn or not alive(LP) then return end
	if not isrbxactive or not isrbxactive() then return end
	local now = tick()
	if now - lastTrig < (S.trigDelay/1000) then return end
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	rp.FilterDescendantsInstances = {LP.Character, Cam}; rp.IgnoreWater = true
	local r = workspace:Raycast(Cam.CFrame.Position, Cam.CFrame.LookVector * 2000, rp)
	if not (r and r.Instance) then return end
	local hp = partToPlayer(r.Instance)
	if not hp or hp == LP or combatSameTeam(hp) or not alive(hp) then return end
	lastTrig = now; fire()
end))

local lastAS = 0
table.insert(Hub.conns, RunService.Heartbeat:Connect(function()
	if not S.autoShoot or not alive(LP) then return end
	if not isrbxactive or not isrbxactive() then return end
	local now = tick()
	if now - lastAS < 0.08 then return end
	local t = closest()
	if not t or not t.Character then return end
	local bp = bonePos(t.Character, S.aimBone)
	if not bp then return end
	if not visible(Cam.CFrame.Position, bp, t.Character) then return end
	lastAS = now; fire()
end))

local lastAC = 0
table.insert(Hub.conns, RunService.Heartbeat:Connect(function()
	if not S.autoClick then return end
	if not isrbxactive or not isrbxactive() then return end
	local now = tick()
	if now - lastAC < (1/math.max(S.cps,1)) then return end
	lastAC = now; fire()
end))

local fovC = Drawing.new("Circle")
fovC.Thickness = 2; fovC.NumSides = 60; fovC.Filled = false
fovC.Transparency = 0.5; fovC.Color = rgb(140,0,255); fovC.Visible = false
table.insert(Hub.draws, fovC)
table.insert(Hub.conns, RunService.RenderStepped:Connect(function()
	local inset = GuiService:GetGuiInset()
	local mp = UserInput:GetMouseLocation()
	fovC.Visible = S.fovShow; fovC.Radius = S.fovRadius
	fovC.Position = Vector2.new(mp.X+inset.X, mp.Y+inset.Y); fovC.Color = S.fovColor
end))

-- ═══════════════════════════════════════
-- ESP (inchangé)
-- ═══════════════════════════════════════
local function makeEsp(p)
	if p==LP then return end
	local uid = tostring(p.UserId)
	if Hub.esps[uid] then return end
	Hub.esps[uid] = {bo=Drawing.new("Square"), b=Drawing.new("Square"), n=Drawing.new("Text"),
		hb=Drawing.new("Square"), h=Drawing.new("Square"), d=Drawing.new("Text"), t=Drawing.new("Line")}
	local o = Hub.esps[uid]
	o.bo.Thickness=3; o.bo.Filled=false; o.bo.Color=rgb(0,0,0); o.bo.Visible=false
	o.b.Thickness=1; o.b.Filled=false; o.b.Visible=false
	o.n.Size=13; o.n.Center=true; o.n.Outline=true; o.n.OutlineColor=rgb(0,0,0); o.n.Visible=false
	o.hb.Thickness=1; o.hb.Filled=true; o.hb.Color=rgb(0,0,0); o.hb.Visible=false
	o.h.Thickness=1; o.h.Filled=true; o.h.Visible=false
	o.d.Size=12; o.d.Center=true; o.d.Outline=true; o.d.OutlineColor=rgb(0,0,0); o.d.Color=rgb(200,200,200); o.d.Visible=false
	o.t.Thickness=1; o.t.Visible=false
end

local function updateEsp(p)
	if p==LP then return end
	local uid = tostring(p.UserId)
	local o = Hub.esps[uid]
	if not o then return end
	local function hide() for _,x in pairs(o) do x.Visible=false end end
	if not S.espOn or espSameTeam(p) or not alive(p) or not alive(LP) then hide(); return end
	local c = p.Character
	local hrp = c:FindFirstChild("HumanoidRootPart")
	local head = c:FindFirstChild("Head")
	local hum = c:FindFirstChildOfClass("Humanoid")
	if not hrp or not head or not hum then hide(); return end
	local rp, os = Cam:WorldToViewportPoint(hrp.Position)
	if not os then hide(); return end
	local hp = Cam:WorldToViewportPoint(head.Position + Vector3.new(0,1.5,0))
	local fp = Cam:WorldToViewportPoint(hrp.Position - Vector3.new(0,3,0))
	local bh = math.abs(hp.Y - fp.Y)
	local bw = bh * 0.55
	local bx = rp.X - bw/2
	local by = hp.Y
	local col = P.accent
	if S.espBox then
		o.bo.Size=Vector2.new(bw,bh); o.bo.Position=Vector2.new(bx,by); o.bo.Visible=true
		o.b.Size=Vector2.new(bw,bh); o.b.Position=Vector2.new(bx,by); o.b.Color=col; o.b.Visible=true
	else o.b.Visible=false; o.bo.Visible=false end
	if S.espName then
		o.n.Text=p.DisplayName; o.n.Position=Vector2.new(rp.X,by-16); o.n.Color=rgb(255,255,255); o.n.Visible=true
	else o.n.Visible=false end
	if S.espHp then
		local pct = math.clamp(hum.Health/hum.MaxHealth,0,1)
		o.hb.Size=Vector2.new(5,bh+2); o.hb.Position=Vector2.new(bx-7,by-1); o.hb.Visible=true
		o.h.Size=Vector2.new(3,bh*pct); o.h.Position=Vector2.new(bx-6,by+bh*(1-pct))
		o.h.Color=Color3.fromRGB(255*(1-pct),255*pct,0); o.h.Visible=true
	else o.h.Visible=false; o.hb.Visible=false end
	if S.espDist and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
		local dist = (LP.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
		o.d.Text=string.format("[%dm]",math.floor(dist)); o.d.Position=Vector2.new(rp.X,fp.Y+2); o.d.Visible=true
	else o.d.Visible=false end
	if S.espTrace then
		o.t.From=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y)
		o.t.To=Vector2.new(rp.X,fp.Y); o.t.Color=col; o.t.Visible=true
	else o.t.Visible=false end
end

table.insert(Hub.conns, RunService.RenderStepped:Connect(function()
	for _,p in ipairs(Players:GetPlayers()) do
		if p~=LP then
			if not Hub.esps[tostring(p.UserId)] then makeEsp(p) end
			updateEsp(p)
		end
	end
end))

table.insert(Hub.conns, Players.PlayerRemoving:Connect(function(p)
	local uid = tostring(p.UserId)
	if Hub.esps[uid] then for _,o in pairs(Hub.esps[uid]) do pcall(function() o:Remove() end) end; Hub.esps[uid]=nil end
	if Hub.hls[uid] then Hub.hls[uid]:Destroy(); Hub.hls[uid]=nil end
end))

table.insert(Hub.conns, RunService.Heartbeat:Connect(function()
	for _,p in ipairs(Players:GetPlayers()) do
		if p==LP then continue end
		local uid = tostring(p.UserId)
		local c = p.Character
		if not S.chams or not c or espSameTeam(p) or not alive(p) then
			if Hub.hls[uid] then Hub.hls[uid]:Destroy(); Hub.hls[uid]=nil end
			continue
		end
		if not Hub.hls[uid] then
			local h = Instance.new("Highlight")
			h.FillColor=rgb(255,0,0); h.OutlineColor=rgb(255,255,255)
			h.FillTransparency=0.5; h.OutlineTransparency=0
			h.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop
			h.Adornee=c; h.Parent=CoreGui
			Hub.hls[uid]=h
		else Hub.hls[uid].Adornee=c end
	end
end))

local extra = {}
table.insert(Hub.conns, RunService.RenderStepped:Connect(function()
	local any = S.headDot or S.snaplines or S.arrows
	for _,p in ipairs(Players:GetPlayers()) do
		if p==LP then continue end
		local function clr()
			local s = extra[p]
			if s then for _,d in pairs(s) do pcall(function() d:Remove() end) end; extra[p]=nil end
		end
		if not any or not alive(p) or espSameTeam(p) then clr(); continue end
		local c = p.Character
		local head = c and c:FindFirstChild("Head")
		if not head then clr(); continue end
		local set = extra[p]
		if not set then
			set = {dot=Drawing.new("Circle"), line=Drawing.new("Line"), arrow=Drawing.new("Triangle")}
			set.dot.Filled=true; set.dot.NumSides=12; set.dot.Radius=3
			table.insert(Hub.draws,set.dot); table.insert(Hub.draws,set.line); table.insert(Hub.draws,set.arrow)
			extra[p]=set
		end
		local hp, os = Cam:WorldToViewportPoint(head.Position)
		local sp = Vector2.new(hp.X, hp.Y)
		set.dot.Visible = S.headDot and os
		if set.dot.Visible then set.dot.Position=sp; set.dot.Color=S.fovColor end
		set.line.Visible = S.snaplines and os
		if set.line.Visible then
			set.line.From=Vector2.new(Cam.ViewportSize.X/2,0); set.line.To=sp; set.line.Color=S.fovColor; set.line.Thickness=1
		end
		if S.arrows and not os then
			local center = Cam.ViewportSize/2
			local dir = sp-center; if dir.Magnitude<1 then dir=Vector2.new(0,-1) end
			dir = dir.Unit
			local edge = center + dir*200
			local perp = Vector2.new(-dir.Y, dir.X)
			set.arrow.Visible=true; set.arrow.Filled=true; set.arrow.Color=S.fovColor
			set.arrow.PointA=edge+dir*14; set.arrow.PointB=edge-dir*10+perp*9; set.arrow.PointC=edge-dir*10-perp*9
		else set.arrow.Visible=false end
	end
end))

-- ═══════════════════════════════════════
-- MOUVEMENT (inchangé)
-- ═══════════════════════════════════════
table.insert(Hub.conns, RunService.Heartbeat:Connect(function()
	if not S.speedOn or not alive(LP) then return end
	local h = LP.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = S.speedVal end
end))

table.insert(Hub.conns, RunService.RenderStepped:Connect(function()
	if not S.flyOn or not alive(LP) then return end
	local hrp = LP.Character:FindFirstChild("HumanoidRootPart"); if not hrp then return end
	local bv = hrp:FindFirstChild("JFly_BV")
	local bg = hrp:FindFirstChild("JFly_BG")
	if not bv then
		bv = Instance.new("BodyVelocity"); bv.Name="JFly_BV"; bv.MaxForce=Vector3.new(math.huge,math.huge,math.huge); bv.Velocity=Vector3.zero; bv.Parent=hrp
		bg = Instance.new("BodyGyro"); bg.Name="JFly_BG"; bg.MaxTorque=Vector3.new(math.huge,math.huge,math.huge); bg.P=9e4; bg.Parent=hrp
	end
	local cf = Cam.CFrame
	local d = Vector3.zero
	if UserInput:IsKeyDown(Enum.KeyCode.W) then d += cf.LookVector end
	if UserInput:IsKeyDown(Enum.KeyCode.S) then d -= cf.LookVector end
	if UserInput:IsKeyDown(Enum.KeyCode.A) then d -= cf.RightVector end
	if UserInput:IsKeyDown(Enum.KeyCode.D) then d += cf.RightVector end
	if UserInput:IsKeyDown(Enum.KeyCode.Space) then d += Vector3.new(0,1,0) end
	if UserInput:IsKeyDown(Enum.KeyCode.LeftControl) then d -= Vector3.new(0,1,0) end
	bv.Velocity = d.Magnitude>0 and d.Unit*S.flySpd or Vector3.zero
	bg.CFrame = cf
end))

table.insert(Hub.conns, RunService.Stepped:Connect(function()
	if not S.noclipOn or not alive(LP) then return end
	for _,part in ipairs(LP.Character:GetDescendants()) do
		if part:IsA("BasePart") then part.CanCollide = false end
	end
end))

table.insert(Hub.conns, UserInput.JumpRequest:Connect(function()
	if not S.infJump or not alive(LP) then return end
	LP.Character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
end))

table.insert(Hub.conns, RunService.Heartbeat:Connect(function()
	if not S.bhop or not alive(LP) then return end
	local h = LP.Character:FindFirstChildOfClass("Humanoid")
	if h and h.MoveDirection.Magnitude > 0 and h.FloorMaterial ~= Enum.Material.Air then
		h:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end))

table.insert(Hub.conns, UserInput.JumpRequest:Connect(function()
	if not S.longJump or not alive(LP) then return end
	local hrp = LP.Character.HumanoidRootPart
	local h = LP.Character:FindFirstChildOfClass("Humanoid")
	if h and h.MoveDirection.Magnitude > 0 then hrp.AssemblyLinearVelocity += h.MoveDirection * S.longVal end
end))

table.insert(Hub.conns, RunService.Heartbeat:Connect(function()
	if not S.sprint or not alive(LP) then return end
	local h = LP.Character:FindFirstChildOfClass("Humanoid")
	if h and h.MoveDirection.Magnitude > 0 then h.WalkSpeed = math.max(h.WalkSpeed, 22) end
end))

table.insert(Hub.conns, mouse.Button1Down:Connect(function()
	if not S.tpMouse or not alive(LP) then return end
	if UserInput:IsKeyDown(Enum.KeyCode.LeftAlt) then
		local hit = mouse.Hit
		if hit then LP.Character.HumanoidRootPart.CFrame = hit + Vector3.new(0,3,0) end
	end
end))

table.insert(Hub.conns, UserInput.JumpRequest:Connect(function()
	if not S.airJump then return end
	local c = LP.Character; local h = c and c:FindFirstChildOfClass("Humanoid")
	if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
end))

table.insert(Hub.conns, RunService.Heartbeat:Connect(function()
	local c = LP.Character; if not c then return end
	local h = c:FindFirstChildOfClass("Humanoid")
	local hrp = c:FindFirstChild("HumanoidRootPart"); if not hrp then return end
	if S.antiFall then
		local v = hrp.AssemblyLinearVelocity
		if v.Y < -90 then hrp.AssemblyLinearVelocity = Vector3.new(v.X, -90, v.Z) end
	end
	if S.jpOn and h then h.UseJumpPower = true; h.JumpPower = S.jpVal end
	if S.gravOn then workspace.Gravity = S.gravVal end
	if S.spider and h and h.MoveDirection.Magnitude > 0 then
		local rp = RaycastParams.new()
		rp.FilterType = Enum.RaycastFilterType.Exclude
		rp.FilterDescendantsInstances = {c}
		local r = workspace:Raycast(hrp.Position, hrp.CFrame.LookVector * 3, rp)
		if r then hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 35, hrp.AssemblyLinearVelocity.Z) end
	end
end))

local fcActive, fcCF, fcYaw, fcPitch = false, CFrame.new(), 0, 0
local fcKeys = {}
table.insert(Hub.conns, UserInput.InputBegan:Connect(function(i,gpe) if not gpe then fcKeys[i.KeyCode]=true end end))
table.insert(Hub.conns, UserInput.InputEnded:Connect(function(i) fcKeys[i.KeyCode]=false end))
RunService:BindToRenderStep("JBT_Freecam", Enum.RenderPriority.Camera.Value + 3, function(dt)
	if S.freecam then
		if not fcActive then
			fcActive=true; fcCF=Cam.CFrame
			local _,y,_ = fcCF:ToOrientation(); fcYaw=y; fcPitch=0
			Cam.CameraType=Enum.CameraType.Scriptable
			UserInput.MouseBehavior=Enum.MouseBehavior.LockCenter
		end
		local d = UserInput:GetMouseDelta()
		fcYaw = fcYaw - d.X*0.004
		fcPitch = math.clamp(fcPitch - d.Y*0.004, -1.4, 1.4)
		local rot = CFrame.fromEulerAnglesYXZ(fcPitch, fcYaw, 0)
		local spd = S.freecamSpd*40*dt
		local mv = Vector3.zero
		if fcKeys[Enum.KeyCode.W] then mv=mv+Vector3.new(0,0,-1) end
		if fcKeys[Enum.KeyCode.S] then mv=mv+Vector3.new(0,0,1) end
		if fcKeys[Enum.KeyCode.A] then mv=mv+Vector3.new(-1,0,0) end
		if fcKeys[Enum.KeyCode.D] then mv=mv+Vector3.new(1,0,0) end
		if fcKeys[Enum.KeyCode.Space] then mv=mv+Vector3.new(0,1,0) end
		if fcKeys[Enum.KeyCode.LeftControl] then mv=mv+Vector3.new(0,-1,0) end
		fcCF = CFrame.new(fcCF.Position)*rot*CFrame.new(mv*spd)
		Cam.CFrame = CFrame.new(fcCF.Position)*rot
	elseif fcActive then
		fcActive=false; Cam.CameraType=Enum.CameraType.Custom; UserInput.MouseBehavior=Enum.MouseBehavior.Default
	end
end)
table.insert(Hub.renders, "JBT_Freecam")

-- ═══════════════════════════════════════
-- VISUELS (inchangé)
-- ═══════════════════════════════════════
table.insert(Hub.conns, RunService.Heartbeat:Connect(function()
	if not S.noFog then return end
	Lighting.FogEnd=1e6; Lighting.FogStart=1e6
	local a = Lighting:FindFirstChildOfClass("Atmosphere"); if a then a.Density=0 end
end))

table.insert(Hub.conns, RunService.RenderStepped:Connect(function()
	if S.camFov then Cam.FieldOfView = S.camFovVal end
end))

table.insert(Hub.conns, RunService.RenderStepped:Connect(function()
	if S.tps then LP.CameraMaxZoomDistance=30; LP.CameraMinZoomDistance=0.5 end
end))

local xLines = {}
for i=1,4 do local l=Drawing.new("Line"); l.Thickness=1; l.Visible=false; l.Color=rgb(0,255,0); xLines[i]=l; table.insert(Hub.draws,l) end
table.insert(Hub.conns, RunService.RenderStepped:Connect(function()
	if not S.xhair then for _,l in ipairs(xLines) do l.Visible=false end; return end
	local cx,cy = Cam.ViewportSize.X/2, Cam.ViewportSize.Y/2
	local s,g = S.xhairSize, 3
	for _,l in ipairs(xLines) do l.Thickness=S.xhairThick; l.Color=S.fovColor; l.Visible=true end
	xLines[1].From=Vector2.new(cx,cy-g-s); xLines[1].To=Vector2.new(cx,cy-g)
	xLines[2].From=Vector2.new(cx,cy+g); xLines[2].To=Vector2.new(cx,cy+g+s)
	xLines[3].From=Vector2.new(cx-g-s,cy); xLines[3].To=Vector2.new(cx-g,cy)
	xLines[4].From=Vector2.new(cx+g,cy); xLines[4].To=Vector2.new(cx+g+s,cy)
end))

table.insert(Hub.conns, RunService.RenderStepped:Connect(function()
	if S.noKillCam then Cam.CameraType = Enum.CameraType.Custom end
end))

table.insert(Hub.conns, RunService.Heartbeat:Connect(function()
	if S.ambient then Lighting.ClockTime = S.ambientTime end
end))

local hitLines = {}
for i=1,4 do local l=Drawing.new("Line"); l.Thickness=2; l.Color=rgb(255,255,255); l.Visible=false; hitLines[i]=l; table.insert(Hub.draws,l) end
local function showHM()
	local c = Cam.ViewportSize/2
	local g,s = 5,12
	local pts = {{c+Vector2.new(g,g),c+Vector2.new(s,s)},{c+Vector2.new(-g,g),c+Vector2.new(-s,s)},
		{c+Vector2.new(g,-g),c+Vector2.new(s,-s)},{c+Vector2.new(-g,-g),c+Vector2.new(-s,-s)}}
	for i,l in ipairs(hitLines) do l.From,l.To,l.Visible = pts[i][1],pts[i][2],true end
	task.delay(0.15, function() for _,l in ipairs(hitLines) do l.Visible=false end end)
end

table.insert(Hub.conns, UserInput.InputBegan:Connect(function(i, gpe)
	if gpe or not S.hitmark then return end
	if i.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
	local rp = RaycastParams.new()
	rp.FilterType = Enum.RaycastFilterType.Exclude
	rp.FilterDescendantsInstances = {LP.Character, Cam}
	local r = workspace:Raycast(Cam.CFrame.Position, Cam.CFrame.LookVector * 2000, rp)
	if r and partToPlayer(r.Instance) and partToPlayer(r.Instance) ~= LP then showHM() end
end))

-- ═══════════════════════════════════════
-- MISC (inchangé)
-- ═══════════════════════════════════════
table.insert(Hub.conns, LP.Idled:Connect(function()
	if S.afk then
		local vr = game:GetService("VirtualUser")
		vr:Button2Down(Vector2.new(0,0), Cam.CFrame)
		task.wait(0.5)
		vr:Button2Up(Vector2.new(0,0), Cam.CFrame)
	end
end))

local function hookRespawn()
	if not LP.Character then return end
	local h = LP.Character:FindFirstChildOfClass("Humanoid"); if not h then return end
	local c
	c = h.Died:Connect(function()
		if S.autoRes or S.instRes then
			task.wait(S.instRes and 0 or 0.5)
			pcall(function() ReplicatedStorage.Remotes.Replication.Fighter.ResetCharacter:FireServer() end)
		end
		c:Disconnect()
	end)
	table.insert(Hub.conns, c)
end
hookRespawn()
table.insert(Hub.conns, LP.CharacterAdded:Connect(function() task.wait(0.5); hookRespawn() end))

-- Watermark HUD
local hud = Instance.new("Frame")
hud.Size = UDim2.new(0, 220, 0, 28)
hud.Position = UDim2.new(0, 12, 0, 12)
hud.BackgroundColor3 = P.panel
hud.BackgroundTransparency = 0.25
hud.BorderSizePixel = 0
hud.Parent = Hub.gui
corner(hud, 9)
stroke(hud, P.accent, 1)
local wmAcc = Instance.new("Frame")
wmAcc.Size = UDim2.new(0,2,0.6,0); wmAcc.Position = UDim2.new(0,0,0.2,0)
wmAcc.BackgroundColor3 = P.accent; wmAcc.BorderSizePixel = 0; wmAcc.Parent = hud
local wmText = Instance.new("TextLabel")
wmText.Size = UDim2.new(1,-10,1,0); wmText.Position = UDim2.new(0,8,0,0)
wmText.BackgroundTransparency = 1; wmText.Text = "💎 4VJ SHOP · v1 paid"
wmText.Font = Enum.Font.GothamBold; wmText.TextSize = 11
wmText.TextColor3 = P.text; wmText.TextXAlignment = Enum.TextXAlignment.Left
wmText.Parent = hud

-- Live stats
local fpsA, fpsC, fpsV = 0, 0, 60
table.insert(Hub.conns, RunService.RenderStepped:Connect(function(dt)
	fpsA = fpsA + dt; fpsC = fpsC + 1
	if fpsA >= 0.5 then fpsV = math.floor(fpsC/fpsA + 0.5); fpsA, fpsC = 0, 0 end
	hud.Visible = S.watermark
	sFPS.Text = fpsV
	sFPS.TextColor3 = fpsV >= 60 and P.accent or (fpsV >= 30 and rgb(255,180,60) or P.bad)
	local ping = 0
	pcall(function() ping = math.floor(LP:GetNetworkPing() * 1000) end)
	sPing.Text = ping.." ms"
	sPing.TextColor3 = ping < 100 and P.accent or (ping < 200 and rgb(255,180,60) or P.bad)
	sPlay.Text = #Players:GetPlayers().."/"..(Players.MaxPlayers or "?")
	if LP.Team then sTeam.Text = LP.Team.Name; sTeam.TextColor3 = LP.Team.TeamColor.Color
	else sTeam.Text = "None"; sTeam.TextColor3 = P.dim end
	if alive(LP) then
		local h = LP.Character:FindFirstChildOfClass("Humanoid")
		local pct = h.Health/h.MaxHealth
		sHP.Text = math.floor(h.Health).."/"..math.floor(h.MaxHealth)
		sHP.TextColor3 = pct > 0.6 and P.accent or (pct > 0.3 and rgb(255,180,60) or P.bad)
	else sHP.Text = "—"; sHP.TextColor3 = P.dim end
end))

-- ═══════════════════════════════════════
-- ANIMATION D'OUVERTURE
-- ═══════════════════════════════════════
Hub.win.Size = UDim2.new(0,10,0,10)
Hub.win.Position = UDim2.new(0.5,-5,0.5,-5)
tw(Hub.win, {Size = UDim2.new(0,800,0,480), Position = UDim2.new(0.5,-400,0.5,-240)}, 0.4, Enum.EasingStyle.Back)
Hub:notify("💎 4VJ SHOP v1 paid · RightCtrl pour toggle", 4)
print("[4VJ Shop] v1 paid loaded — GUI corrigé, palettes, langue complète")
return Hub
