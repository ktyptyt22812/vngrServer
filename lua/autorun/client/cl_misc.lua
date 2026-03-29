
local function AddScroll(pnl, power, enable)
    if not pnl:GetBool(enable) then return end

    local data = {
        doing_scroll = false,
        tScroll      = 0,
        newerT       = 0,
        Old_Pos      = 0,
        Old_Sign     = 0,
    }

    local function getBiggerPos(delta, oldScroll)
        return oldScroll + delta
    end

    local anim = pnl:NewAnimation(0.2) 

    pnl.Think = function(self)
        local ctime = RealTime()
        local delta = ctime - data.newerT
        data.newerT = ctime

        if not data.doing_scroll then return end

        local StartPos  = data.Old_Pos
        local TargetPos = data.tScroll
        local fraction  = anim:GetFloat()

        local nowpos = Lerp(fraction, StartPos, TargetPos)
        nowpos = math.Clamp(nowpos, 0, pnl:CanvasSize())

        pnl:SetScroll(nowpos)

        if nowpos == TargetPos then
            data.doing_scroll = false
        end

        data.Old_Sign = data.tScroll - nowpos > 0 and 1 or -1
        data.Old_Pos  = pnl:GetScroll()
    end

    local OldScroll = pnl.OnMouseWheeled
    pnl.OnMouseWheeled = function(self, scroll)
        local oldScroll = self:GetScroll()
        local tScroll   = getBiggerPos(scroll * power, oldScroll)
        tScroll = math.Clamp(tScroll, 0, self:CanvasSize())

        data.Old_Pos      = oldScroll
        data.tScroll      = tScroll
        data.doing_scroll = true
        data.newerT       = RealTime()

        anim:NewAnimation(0.2)
    end
end

net.Receive("classicbox_timer", function()
    local time     = net.ReadUInt(32)
    local is_red   = net.ReadBool()

    local col = is_red and Color(255, 80, 80) or color_white

    chat.AddText(col, tostring(time))
end)

net.Receive("hitmarker_hit", function()
    if not GetConVar("himarkers"):GetBool() then return end

    local is_headshot = net.ReadBool()

    if is_headshot then
        surface.PlaySound("rust_headshot.wav")
    else
        surface.PlaySound("rust_hitmarker.wav")
    end
end)

net.Receive("hitmarker_killhit", function()
    if not GetConVar("killeffect"):GetBool() then return end

    surface.PlaySound("rust_headshot.wav")

    LocalPlayer():ScreenFade(
        SCREENFADE.IN,
        Color(180, 0, 0, 100),
        0.3, 
        0.1   
    )
end)
local Otsos = ScrW() / 3

local function getPngFilehttp(link, name)
    http.Fetch(link, function(body)
        file.Write('gearbox/' .. name .. '.png', body)
    end)
end

local function rmgavno()
    if not g_SpawnMenu or not IsValid(g_SpawnMenu.CreateMenu) then return end
    
    local items = g_SpawnMenu.CreateMenu.Items
    for i = #items, 1, -1 do 
        local v = items[i]
        if v and v.Tab:IsValid() then
            local txt = v.Tab:GetText()
            if txt == language.GetPhrase("spawnmenu.category.postprocess") or
               txt == language.GetPhrase("spawnmenu.category.dupes") or
               txt == language.GetPhrase("spawnmenu.category.saves") then
                g_SpawnMenu.CreateMenu:CloseTab(v.Tab, true)
            end
        end
    end
end
hook.Add("SpawnMenuOpen", "rmgavno", rmgavno)

surface.CreateFont("MainMenu", {
    font = "Roboto",
    size = 32
})

for _, v in pairs({
    "gearbox_prop_info", "gearbox_prop_xyz", "gearbox_show_hud", 
    "gearbox_show_deadnotify", "gearbox_show_notify", 
    "gearbox_show_chat_screen", "gearbox_load_addons", "gearbox_disconnect_animation"
}) do
    if not ConVarExists(v) then CreateClientConVar(v, "1", true, false) end
end


/*
local Obshee = {
["Для Всех"] = {
	["Режимы"] = {
		types = "chat",
		trasncript = "Режим Строителя доступны всем рангам игроков исклучая нарушителей.",
		Full = "Режим строителя сделает ваши предметы неуязвимыми к ACF оружию и Вас к любому типу урона.",
		Cmds = {"!b, !build, !p, !pvp | Все команды имеют TOGGLE модофикацию."}
	},
	["Кастомный спавнпоинт"] = {
		types = "chat",
		trasncript = "Вы можете установить свой собчтвенный спавн.",
		Full = "Вы будете появлятся на выбранной вами точке, если вас убьют за 2 секунды после спавна - вы потеряете спавнпоинт.",
		Cmds = {"!s - устанавливает спавнопоинт","!rs - удаляет спавнпоинт"}
	},
},
["Для Привилигированных"] = {},
["Для Администрации"] = {}
}
*/



local Buttonss = {}
local Cmd = {
{"","Информация"},
{"http://steamcommunity.com/sharedfiles/filedetails/?id=838964367","Ссылка на коллекцию аддонов"},
{"Все лимитеры были установлены на 9999", "Злоупотребление лимитами приведет к вашей перманентной блокировке" },
{"Камера","Взяв в руки камеру нажав LALT + M1 вы сделаете скриншот"},
{"Prop Info","Нажав LALT + 1-7 вы скопируете параметр обьекта"},


{"","Чат команды"},
{"  !build , !pvp", "  Переводит вас в режим Build или PVP" },
{"  !s","  Устанавливает кастомный спавнпоинт"},
{"  !rs","  Удаляет кастомный спавнпоинт"},
{"","Чат команды для привилегированных"},
{"  !a","  Принять/Сдать пост админа - вас автоматически будет телепортировать к нарушителям"},
{"  !w","  Отключает действие антилага на вас (до 3 лвла)."},
{"","Консольные команды"},
{"  gearbox_screenshot","Делает скриншот экрана и отслыает всем на сервере(в вк и дискорд)"},
{"","Ресурсы и приколы"},
{"  !key","Введя в чат данную команду вы получите инструкцию по входу в беседу в вк"},
{"  https://discord.gg/RQMxwR3","Приглашение в дискорд"},
}
local CmdK = #Cmd

local Set = {
{"gearbox_prop_info","Показывать информацию о пропах"},
{"gearbox_prop_xyz","Показывать вектора XYZ на пропах"},
{"gearbox_show_hud","Показывать худ"},
{"gearbox_show_deadnotify","Показывать оповещения смерти игроков"},
{"gearbox_show_notify","Показывать подсказки(нотификации)"},
{"gearbox_show_chat_screen","Показывать картинки(ссылки)"},
{"gearbox_load_addons","Загружать аддоны при спавне"},
{"gearbox_disconnect_animation","Показывать анимацию выхода игрока"},
}
local SetK = #Set





local Rules = " 1 Общие правила\n\n   ЗЛОУПОТРЕБЛЕНИЕ лимитами приведет к вашей перманентной блокировке.\n    Администрация имеет право вмешиваться в игровой процесс в любое время и действовать “по ситуации”\n    Администрация самостоятельно выносит наказание (продолжительность бана и т.п.)\n    Действия администрации могут быть обусловлены следующими пунктами:\n\n    1.1 Угроза нормальной работоспособности сервера.\n    1.2 Помеха приемлемой игровой среде для пользователей.\n    1.3 Независимо от статуса игрока (Строитель, Модератор, Кодер) - все равны и все понесут наказание за нарушение правил.\n    1.4 Последнее слово всегда за администрацией.\n    1.5 Любые сторонние ресурсы виртуальной связи, к примеру Skype, Вконтакте (не затрагивающие рамки сервера) не имеют никакого отношения к игровому процессу и доказательства, основанные на этом не принимаются в расчет.\n\n 2 Правила чата\n\n    2.1 Запрещено писать сообщения не несущие, в общем, никакой логики.\n        Например: “рарарар”\n    2.2 Запрещено писать одинаковые сообщения в чат (флудить).\n        Флудом считается написание от 3 идентичных сообщений подряд (имеющих похожий смысл)\n    2.3 Запрещена дискриминация игроков, насмешки, унижение человеческого достоинства, угрозы.\n    2.4 Запрещается написание сообщений сексуального характера или текста содержащего ненормативную лексику, завуалированный мат.\n    2.5 Запрещается оскорбление или упоминание родственников.\n\n 3 Правила игрового процесса\n\n    3.1 Запрещено совершать действия провоцирующие сильную нагрузку сервера.\n    3.2 Запрещен Spawncamping, а также PropPush/PropBlock.\n    3.3 Запрещено убийство в build/god/noclip модах.\n    3.4 Запрещено мешать - препятствовать комфортным условиям игры.\n    3.5 Не желательно применение E2kill/Wirekill и систем чьи создатели недосягаемы для убийства.\n    3.6 Если игрок прибывает в AFK на протяжении 1800 секунд, администратор имеет право кикнуть игрока.\n    3.7 Администратор имеет право наказать вас по причине не входящей в рамки данного свода правил, при условии, что большинство привилегированных игроков согласны с решением."
 Rules = string.Explode("\n",Rules)
local RuleK = #Rules

local function Saved() 
    local  t = {}
    for k,v in pairs(Set) do 
            local Cvar = GetConVar( v[1] ):GetInt()     
            table.insert(t,math.Round(Cvar,0)) 

    end
  	            local Json =  util.TableToJSON(t)
  	            chat.AddText("Настройки сохранены > gearbox/settings.txt")
    file.Write( 'gearbox/settings.txt', Json )


end



local InfoPanel
spawnmenu.AddCreationTab("GB", function()
    local Buttonss = {} 
    local InfoPanel

    local Main = vgui.Create("DPanel")
    Main:Dock(FILL)
    Main:DockMargin(5, 0, 5, 0)
    Main.Paint = function(self, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(25, 25, 25, 200))
        surface.SetDrawColor(0, 255, 255, 255)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    local function Dupdate(p)
        if not IsValid(InfoPanel) then return end
        for _, v in pairs(InfoPanel:GetChildren()) do v:Remove() end
            
        if p == 1 then
            local Scroll = vgui.Create("DScrollPanel", InfoPanel)
            Scroll:Dock(FILL)
            for _, v in pairs(Rules) do
                local R = Scroll:Add("DButton")
                R:Dock(TOP)
                R:SetText("")
                if v == "" then R:SetHeight(5) R.Paint = nil 
                else
                    R:SetHeight(35)
                    R.Lerp = 0
                    R.Paint = function(self, w, h)
                        local hovered = self:IsHovered()
                        draw.RoundedBox(0, 1, 1, w - 2, h - 2, hovered and Color(0, 0, 0, 200) or Color(25, 25, 25, 250))
                        draw.SimpleText(v, "DermaDefault", 10, h/2, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                    end
                    R.DoClick = function() chat.AddText(Color(255, 255, 255), v) end
                end
            end
        elseif p == 2 then 
            local Scroll = vgui.Create("DScrollPanel", InfoPanel)
            Scroll:Dock(FILL)
            for k, v in pairs(Cmd) do
                local R = Scroll:Add("DButton")
                R:Dock(TOP)
                R:SetHeight(v[1] == "" and 35 or 60)
                R:SetText("")
                R.Paint = function(self, w, h)
                    local col = v[1] == "" and Color(75, 75, 75, 50) or Color(35, 35, 35, 200)
                    draw.RoundedBox(4, 2, 2, w-4, h-4, col)
                    draw.SimpleText(v[2], "DermaDefault", 10, 10, Color(255,255,255))
                    draw.SimpleText(v[1], "DermaDefault", 10, 30, Color(0, 255, 255))
                end
            end
elseif p == 3 then
            local Scroll = vgui.Create("DScrollPanel", InfoPanel)
            Scroll:Dock(FILL)
            Scroll.Paint = nil

            local Fix = nil -

            for k, v in pairs(Set) do
 
                timer.Simple(k * 0.1, function()

                    if not IsValid(Scroll) then return end

                    if (k != SetK) then
                        surface.PlaySound("gearbox/ui/tick.wav")
                    else
                        surface.PlaySound("gearbox/ui/cc.wav")
                    end

                    local CM = v[1]
                    local OP = v[2]
                    local Cvar = GetConVar(CM)
                    if not Cvar then return end 

                    local BB = Scroll:Add("DButton")
                    BB:Dock(TOP)
                    BB:SetHeight(50)
                    BB:SetText("")
                    BB.tumbler = Cvar:GetBool()

                    BB.Paint = function(self, w, h)
                        local T = self.tumbler
                        draw.RoundedBox(0, 2, 2, w - 4, h - 4, T and Color(25, 35, 25) or Color(35, 25, 25))
                        draw.DrawText(T and OP or "Не " .. OP, "MainMenu", 10, 10, Color(255, 255, 255), TEXT_ALIGN_LEFT)
                        surface.SetDrawColor(T and Color(25, 255, 25, 255) or Color(255, 25, 25, 255))
                        surface.DrawOutlinedRect(1, 1, w - 2, h - 2)
                    end

                    BB.DoClick = function(self)
                        self.tumbler = !self.tumbler
                        Cvar:SetBool(self.tumbler)
                        local S = self.tumbler and "on" or "off"
                        surface.PlaySound("gearbox/ui/" .. S .. ".wav")

                        -- Если кнопки сохранения еще нет, создаем её
                        if IsValid(Fix) then return end
                        
                        local SaveBtn = Scroll:Add("DButton")
                        Fix = SaveBtn -- Запоминаем, что кнопка создана
                        SaveBtn:Dock(TOP)
                        SaveBtn:SetHeight(50)
                        SaveBtn:SetText("")
                        SaveBtn.Paint = function(self, w, h)
                            draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(50, 90, 90))
                            draw.DrawText("Сохранить", "MainMenu", 10, 10, Color(255, 255, 255), TEXT_ALIGN_LEFT)
                        end
                        SaveBtn.DoClick = function()
                            SaveBtn:Remove()
                            surface.PlaySound("gearbox/ui/levelup.wav")
                            Saved()
                            Fix = nil
                        end
                    end
                end)
            end
        end 
    end 

    local Header = Main:Add("DPanel")
    Header:Dock(TOP)
    Header:SetHeight(40)
    Header.Paint = function(self, w, h)
        draw.SimpleText("GearBox", "MainMenu", w/2, h/2, Color(0, 255, 255), 1, 1)
    end

    local BtnBar = Main:Add("DPanel")
    BtnBar:Dock(TOP)
    BtnBar:SetHeight(35)

    InfoPanel = Main:Add("DPanel")
    InfoPanel:Dock(FILL)
    InfoPanel.Paint = function(self, w, h)
        surface.SetDrawColor(255, 255, 255, 50)
        surface.DrawOutlinedRect(0, 0, w, h)
    end

    local tabs = { { "Правила", 1 }, { "Общее", 2 }, { "Настройки", 3 } }
    for _, data in ipairs(tabs) do
        local b = BtnBar:Add("DButton")
        b:Dock(LEFT)
        b:SetWidth(150)
        b:SetText(data[1])
        b:SetTextColor(Color(255,255,255))
        b.DoClick = function()
            Dupdate(data[2])
        end
    end

    Dupdate(1) 
    return Main
end, "icon16/cog.png")