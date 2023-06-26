local AeroEvent = TriggerServerEvent
LTDItem = {
    {name = 'burger', label = 'Hamburger', price = 10},
    {name = 'water', label = 'Eau de source', price = 10},
    {name = 'phone', label = 'Téléphone', price = 500},
    {name = 'radio', label = 'Radio', price = 150},
    --{name = 'fishingrod', label = 'Canne à pêche', price = 35},
    --{name = 'fishbait', label = 'Appât de poisson', price = 15},
}

--LTDItemGold = {
    --{name = 'cafe', label = 'Café - VIP ~p~Gold', price = 50},
    --{name = 'donut', label = 'Donut - VIP ~p~Gold', price = 50},
--}

--LTDItemDiamond = {
    --{name = 'jusleechi', label = 'Jus de Leechi - VIP ~p~Diamond', price = 50},
    --{name = 'hotdog', label = 'Hot-dog - VIP ~p~Diamond', price = 50},
--}

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('modo:LeyRider', function(obj) ESX = obj end)
        Citizen.Wait(1)
    end
end)

local function compareItems(item1,item2)
    return item1.label < item2.label
end

local function getListLengh(list)
    i = 0
    for _,__ in pairs(list) do
        i = i + 1
    end
    return i
end

local function getCartPrice(cart)
    price = 0
    for _,v in pairs(cart) do
        price = price + v.price*v.number
    end
    return price
end


function OpenMenuLtd()
    local cartItems = {}
    local menu = RageUI.CreateMenu("", "Articles disponibles :")
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed, true)
    pos = playerCoords

    print(playerPed, pos, playerCoords, GetDistanceBetweenCoords(playerCoords,pos,true))

    RageUI.Visible(menu, not RageUI.Visible(menu))

    while menu do
        Wait(0)
        RageUI.IsVisible(menu, function()
        for k,v in pairs(LTDItem) do
            RageUI.Button(v.label, nil, {RightLabel = "~p~".. v.price.."$"}, true, {
                onSelected = function()
                    playerCoords = GetEntityCoords(playerPed, true)
                    if GetDistanceBetweenCoords(playerCoords, pos, true) > 20 then
                        RageUI.CloseAll()
                        ESX.ShowNotification("~p~Vous êtes trop loin pour éffectuer cette action") 
                        return
                    end
                    table.insert(cartItems,v)
                end
            })
        end
        --[[for k,v in pairs(LTDItemGold) do
            RageUI.Button(v.label, nil, {RightLabel = "~p~".. v.price.."$"}, true, {
                onSelected = function()
                    local vip = exports.Mowgli:GetVIP()
                    if vip ~= 0 then
                        OpenMenuPaiement(v.name, v.price)
                    else
                        ESX.ShowNotification(' ~n~Vous devez être minimum VIP ~p~Gold')
                    end
                end
            })
        end
        for k,v in pairs(LTDItemDiamond) do
            RageUI.Button(v.label, nil, {RightLabel = "~p~".. v.price.."$"}, true, {
                onSelected = function()
                    local vip = exports.Mowgli:GetVIP()
                    if vip == 2 then
                        OpenMenuPaiement(v.name, v.price)
                    else
                        ESX.ShowNotification(' ~n~Vous devez être minimum VIP ~p~Diamond')
                    end
                end
            })
        end]]
        RageUI.Separator()
        RageUI.Button("Panier",nil,{},true,{
            onSelected = function()
                OpenMenuCart(pos,playerPed,cartItems)
            end
        })
        end, function()
        end)

        if not RageUI.Visible(menu) then
            menu = RMenu:DeleteType('menu', true)
        end
    end
end

function OpenMenuCart(pos,playerPed,cartItems)
    local menu = RageUI.CreateMenu("","Panier")
    RageUI.Visible(menu,not RageUI.IsVisible(menu))
    displayCartItems = {}
    table.sort(cartItems, compareItems)
    for _,item in pairs(cartItems) do
        local label = item.label
        if displayCartItems[label] then
            displayCartItems[label].number = displayCartItems[label].number + 1
        else
            displayCartItems[label] ={ 
                number = 1,
                label = label,
                name = item.name,
                price = item.price,
            }
        end
    end


    while menu do
        Wait(0)
        RageUI.IsVisible(menu,function()
            if getListLengh(displayCartItems) == 0 then
                RageUI.Button("Le panier est vide",nil,{},false)
            else
                for k,v in pairs(displayCartItems) do
                    RageUI.Button(v.label.." x"..v.number,nil,{RightLabel = "~p~".. v.price*v.number.."$"}, true, {
                        onSelected = function()
                            print()
                            if v.number > 1 then
                                displayCartItems[v.label].number = displayCartItems[v.label].number - 1 
                            else
                                displayCartItems[k] = nil
                            end
                        end
                    })
                end
            end

            RageUI.Separator()
            if getListLengh(displayCartItems) ~= 0 then
                RageUI.Button("Acheter",nil,{RightLabel = "~p~".. getCartPrice(displayCartItems).."$"},true,{
                    onSelected = function()
                        OpenMenuPaiement(pos,playerPed,displayCartItems)
                    end
                })
            end
        end)
    end
end

function   OpenMenuPaiement(pos,playerPed,displayCartItems)
    local menu = RageUI.CreateMenu("", "Comment voulez vous payer ?")

    RageUI.Visible(menu, not RageUI.Visible(menu))

    while menu do
        Wait(0)
        RageUI.IsVisible(menu, function()
        RageUI.Button('Payer en Liquide', nil, {}, true, {
            onSelected = function()
                playerCoords = GetEntityCoords(playerPed, true)
                print(GetDistanceBetweenCoords(playerCoords,pos,true), pos, playerCoords)
                if GetDistanceBetweenCoords(playerCoords,pos,true) > 5 then
                    RageUI.CloseAll()
                    ESX.ShowNotification("~p~Vous êtes trop loin pour éffectuer cette action")
                    return
                end
                RageUI.CloseAll()
                for _, item in pairs(displayCartItems) do
                    for i=1, item.number do
                        AeroEvent('core:achat', item.name, item.price, 1)
                    end
                end
            end
        })
        RageUI.Button('Payer par Carte Bancaire', nil, {}, true, {
            onSelected = function()
                playerCoords = GetEntityCoords(playerPed, true)
                if GetDistanceBetweenCoords(playerCoords,pos,true) > 5 then
                    RageUI.CloseAll()
                    ESX.ShowNotification("~p~Vous êtes trop loin pour éffectuer cette action")
                    return
                end
                RageUI.CloseAll()
                for _, item in pairs(cartItems) do
                    for i=1, item.number do
                        AeroEvent('core:achat', item.name, item.price, 2)
                    end
                end
            end
        })

        end, function()
        end)

        if not RageUI.Visible(menu) then
            menu = RMenu:DeleteType('menu', true)
        end
    end
end
