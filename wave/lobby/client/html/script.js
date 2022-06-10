$(document).ready(function() 
{
    //$('body').hide()

    $('iframe').attr('src', "http://paradigm.mp/wave-survival-changelog?ts=" + new Date().getTime());

    let map_data = {}
    let queue_data = {}
    let player_data = {}
    let my_id = -1

    let shop_data = {} // Shop items
    let shop_data_map_name_to_id = {}
    let shop_loaded = false

    let map_data_initialized = false

    let selected_map = ""
    let selected_difficulty = "easy"

    const offset = 201; // 2 * pi * r

    const $map_entries = $('div.map-entries')
    const $map_details = $('div.map-details')
    const $map_details_players = $('div.map-details div.map-players')
    const $map_image = $('div.map-image')
    const $players_container = $('div.players-container')
    const $shop_container = $('div.shop-container')

    ResetUI();

    let countdown = 
    {
        max: 0,
        current: 0,
        interval: null
    }

    // Play lobby music
    const music = new Audio('http://paradigm.mp/resources/zs/lobbymusic.ogg');
    music.volume = 0.25;
    music.loop = true;
    music.play();

    function ResetUI()
    {
        $('div.countdown-container').hide()

        $map_details_players.empty()
        $players_container.empty()
        $map_entries.empty()
        $shop_container.empty()

        UpdateJoinedAndReadyButtons()
    }

    function CountdownSync(args)
    {
        countdown.max = args.max
        countdown.current = args.current

        if (countdown.interval != null)
        {
            clearInterval(countdown.interval)
        }

        if (countdown.timeout != null)
        {
            clearTimeout(countdown.timeout)
        }

        if (!args.active)
        {
            $('div.countdown-container').hide()
            return;
        }

        UpdateCountdown(countdown.current, countdown.current / countdown.max, true)

        // Do this to get the progress circle moving sooner
        setTimeout(() => {
            UpdateCountdown(countdown.current, (countdown.current - 1) / countdown.max, false)
        }, 60);

        countdown.interval = setInterval(() => {
            countdown.current -= 1

            UpdateCountdown(countdown.current, (countdown.current - 1) / countdown.max, false)
            if (countdown.current == 0)
            {
                $('div.countdown-container').hide()
                clearInterval(countdown.interval)
                return;
            }

        }, 1000);

        $('div.countdown-container').show()
    }

    // Updates the countdown clock
    function UpdateCountdown(time, percent, instant)
    {
        if (instant)
        {
            $('div.countdown-container svg.progress circle.fill').css('transition', 'none');
        }

        $('div.countdown-container div.countdown').text(time);
        $('div.countdown-container svg.progress circle.fill').css("stroke-dashoffset", (1 - percent) * offset);

        if (time == 0)
        {
            countdown.timeout = setTimeout(() => {
                $('div.countdown-container').hide()
            }, 1000);
        }

        setTimeout(() => {
            $('div.countdown-container svg.progress circle.fill').css('transition', '1s linear all');
        }, 50);
    }

    // Gets rid of all difficulties so you can add a new one
    function ClearDifficultyClass(elem)
    {
        elem.removeClass('easy').removeClass('medium').removeClass('hard').removeClass('gunslinger')
    }

    function FullQueueSync(args)
    {
        queue_data = args;

        // If the maps haven't been loaded yet, wait
        if (!map_data_initialized)
        {
            setTimeout(() => {
                FullQueueSync(args)
            }, 200);
            return;
        }

        // Create player dots for each map
        Object.keys(map_data).forEach((mapname) => {
            if (queue_data[mapname])
            {
                CreateSmallMapQueueCircles($(`#mape${map_data[mapname].id}`), mapname)
            }
        })

        $('div.countdown-container').hide()
        $map_details_players.empty()
        UpdateJoinedAndReadyButtons()
    }

    function FullMapSync(args)
    {
        map_data = args

        Object.keys(map_data).forEach((mapname) => {
            CreateMapEntry(map_data[mapname])

            if (selected_map.length == 0)
            {
                SelectMap(mapname)
            }
        });

        map_data_initialized = true
    }

    function CreateMapEntry(map)
    {
        const $elem = $(`<div class='map-entry' id='mape${map.id}'><div class='bg'></div><div class='title'>${map.name}</div></div>`)
        CreateSmallMapQueueCircles($elem, map.name)
        $map_entries.append($elem)
    }

    function CreateSmallMapQueueCircles($map_entry, mapname)
    {
        $map_entry.find('div.players').remove()
        // Create circles of queued players for each map
        if (queue_data[mapname])
        {
            Object.keys(queue_data[mapname]).forEach((difficulty) => {
                if (Object.keys(queue_data[mapname][difficulty]).length > 0)
                {
                    const $difficulty_sec = $(`<div class='players ${difficulty}'>${difficulty}: <div class='players-queued-count'></div>
                    <div class='white'>Players</div> 
                    <div class='players-ready-count'>
                        (
                            <div class='count'></div> Ready
                        )
                    </div>`)
                    const queued_count = GetNumPlayers(queue_data[mapname][difficulty]);
                    $difficulty_sec.find('div.players-queued-count').text(queued_count);
                    const ready_count = GetNumReadyPlayers(queue_data[mapname][difficulty])
                    $difficulty_sec.find('div.players-ready-count div.count').text(ready_count)

                    $map_entry.append($difficulty_sec)
                }
            });
        }
    }

    function GetNumPlayers(queue)
    {
        let cnt = 0
        for (const index in queue) 
        {
            if (queue.hasOwnProperty(index) && queue[index] != null) 
            {
                cnt++;
            }
        }
        return cnt
    }

    // Gets the number of ready players for a specific queue
    function GetNumReadyPlayers(queue)
    {
        let cnt = 0
        for (const index in queue) 
        {
            if (queue.hasOwnProperty(index) && queue[index] != null) 
            {
                const data = queue[index]
                cnt = (data.ready) ? cnt + 1 : cnt;
            }
        }
        return cnt
    }

    function SingleQueueSync(args)
    {
        queue_data[args.name][args.difficulty] = args.data

        CreateSmallMapQueueCircles($(`#mape${map_data[args.name].id}`), args.name)
        // If they have the map open, update the details
        if (selected_map == args.name && selected_difficulty == args.difficulty)
        {
            GenerateLargePlayerAvatarCircles(args.name)
        }

        UpdateJoinedAndReadyButtons()
    }

    function UpdateJoinedAndReadyButtons()
    {
        $('div.button.map-join').removeClass('selected')
        $('div.button.map-join').removeClass('switch')
        $('div.button.map-ready').removeClass('selected')
        $('div.button.map-join').text('Join')

        Object.keys(queue_data).forEach((mapname) => {
            Object.keys(queue_data[mapname]).forEach((difficulty) => {
                if (Object.keys(queue_data[mapname][difficulty]).length > 0)
                {
                    for (const index in queue_data[mapname][difficulty]) 
                    {
                        if (queue_data[mapname][difficulty].hasOwnProperty(index) && queue_data[mapname][difficulty][index] != null) 
                        {
                            const data = queue_data[mapname][difficulty][index]

                            if (data.id == my_id)
                            {
                                $('div.button.map-join').addClass('selected')
                                $('div.button.map-join').text('Leave')

                                if (selected_difficulty != difficulty || selected_map != mapname)
                                {
                                    $('div.button.map-join').addClass('switch')
                                    $('div.button.map-join').text('Switch')
                                }

                                if (data.ready)
                                {
                                    $('div.button.map-ready').addClass('selected')
                                }
                            }
                        }
                    }
                }
            })
        })

        UpdateReadyButtonVisibility()
    }

    function UpdateReadyButtonVisibility()
    {
        if ($('div.button.map-join').hasClass('selected'))
        {
            $('div.button.map-ready').show()
        }
        else
        {
            $('div.button.map-ready').hide()
        }
    }

    // Called when a game starts or finishes
    function QueueGameSync(args)
    {
        if (args.start)
        {
            $('div.map-container').hide()
            $('div.map-gameinprogress-container').show()

            // args.mapname, args.difficulty
            $('div.content-container div.map-image div.title').text(args.mapname)
            const $difficulty = $('div.content-container div.map-image div.difficulty')
            ClearDifficultyClass($difficulty)
            $difficulty.addClass(args.difficulty)
            $difficulty.text(args.difficulty)
            $('div.content-container div.map-image').css('background-image', `url('${map_data[args.mapname].image}')`)
        }
        else
        {
            $('div.map-container').show()
            $('div.map-gameinprogress-container').hide()
        }
    }

    function FullPlayersSync(args)
    {
        player_data = args

        for (const player_id in player_data) 
        {
            if (player_data.hasOwnProperty(player_id)) 
            {
                if (player_data[player_id].is_me)
                {
                    my_id = player_id;
                }
                CreatePlayer(player_data[player_id])
            }
        }
        RefreshAllPlayerAvatars()
    }

    function SinglePlayerSync(args)
    {
        if (args.action == "update")
        {
            if ($(`#peplo${args.id}`).length > 0)
            {
                UpdatePlayer(args)
            }
        }
        else if (args.action == "remove")
        {
            $(`#peplo${args.id}`).remove()
        }
        else if (args.action == "add")
        {
            if ($(`#peplo${args.id}`).length == 0)
            {
                CreatePlayer(args)
            }
        }
        RefreshAllPlayerAvatars()
    }

    // Creates a player entry on the left side of lobby
    function CreatePlayer(data)
    {
        if ($(`#peplo${data.id}`).length != 0) {return;}
        
        const $entry = $(`<div class='players-entry' id='peplo${data.id}'>
            <div class='icon circle rdc${data.id}'></div>
            <div class='name'></div>
            <div class='level'>lvl <div class='val'></div></div>
        </div>`)
        $entry.find('div.icon.circle').css('background-image', data.avatar || '')
        $entry.find('div.name').text(data.name)
        $entry.find('div.level div.val').text(data.level || "?")

        $players_container.append($entry)
    }

    // Comes with avatar, level, 
    function UpdatePlayer(data)
    {
        player_data[data.id] = data
        if (data.avatar)
        {
            $(`div.rdc${data.id}`).css('background-image', `url('${player_data[data.id].avatar || "images/question.png"}')`)
        }

        if (data.level)
        {
            $(`#peplo${data.id}`).find('div.level div.val').text(data.level)
        }
    }

    // Refreshes all player avatars on the right side
    function RefreshAllPlayerAvatars()
    {
        for (const index in player_data) 
        {
            if (player_data.hasOwnProperty(index) && player_data[index] != null) 
            {
                const data = player_data[index]
                $(`div.rdc${data.id}`).css('background-image', `url('${data.avatar || "images/question.png"}')`)
            }
        }
    }

    // Called when the user clicks a top section button to switch
    // section can be LOBBY, SHOP, or LEADERBOARDS
    function SwitchSection(section)
    {
        $('div.section-container').hide()
        $(`div.section-container.section-${section.toLowerCase()}`).show()
    }

    function SelectMap(mapname)
    {
        $("div.map-entry").removeClass("selected")
        $(`#mape${map_data[mapname].id}`).addClass("selected")
        
        selected_map = mapname
        const data = map_data[mapname]
        $map_details.find('div.title').text(mapname)
        let $difficulty = $map_details.find('div.difficulty')
        ClearDifficultyClass($difficulty)
        $difficulty.addClass(selected_difficulty)
        $difficulty.text(selected_difficulty)
        
        GenerateLargePlayerAvatarCircles(mapname)

        // Update map image
        $map_image.css('background-image', `url('${data.image}')`);
        $map_image.find('div.title').text(mapname)
        $difficulty = $map_image.find('div.difficulty')
        ClearDifficultyClass($difficulty)
        $difficulty.addClass(selected_difficulty)
        $difficulty.text(selected_difficulty)

        UpdateJoinedAndReadyButtons()
    }

    function GenerateLargePlayerAvatarCircles(mapname)
    {
        // Generate circles for players
        $map_details_players.empty()
        if (queue_data[mapname] && queue_data[mapname][selected_difficulty])
        {
            for (const index in queue_data[mapname][selected_difficulty]) 
            {
                if (queue_data[mapname][selected_difficulty].hasOwnProperty(index) && queue_data[mapname][selected_difficulty][index] != null) 
                {
                    const data = queue_data[mapname][selected_difficulty][index]
                    const $elem = $(`<div class='player-entry${data.ready ? ' ready' : ''} rdc${data.id}'></div>`)
                    if (player_data[data.id] != null && player_data[data.id].avatar)
                    {
                        $elem.css('background-image', `url('${player_data[data.id].avatar || "images/question.png"}')`)
                    }
                    $map_details_players.append($elem)
                }
            }
        }
    }

    function JoinLeaveButton(joined)
    {
        NAPI.CallEvent('lobby/joinleavebutton', {joined: joined, mapname: selected_map, difficulty: selected_difficulty});
    }

    function ReadyUpButton(ready)
    {
        NAPI.CallEvent('lobby/readyupbutton');
    }

    function GetItemName(item)
    {
        return `${item.model}_${item.outfit}`
    }

    function LoadShopItems(args)
    {
        // Called by the server with info of all the shop items
        shop_data = args.data;
        shop_data_map_name_to_id = {}

        for (const index in shop_data)
        {
            const item_data = shop_data[index];
            const $entry = $(`<div class='shop-entry' id='SI_${item_data.id}'></div>`);
            $entry.append(`<img class='image' src='http://paradigm.mp/resources/zs/images/${GetItemName(item_data)}.JPG'></img>`);
            $entry.append(`<div class='cost'>$${(item_data.cost / 100).toFixed(2)}</div>`);
            $entry.append(`<div class='buy-equip'>Buy</div>`);
            $entry.append(`<div class='ownership-indicator'></div>`);

            $shop_container.append($entry);

            shop_data_map_name_to_id[GetItemName(item_data)] = item_data.id
        }

        shop_loaded = true
    }

    function ShopNetworkValChanged(args)
    {
        if (!shop_loaded)
        {
            setTimeout(() => {
                ShopNetworkValChanged(args)
            }, 1000);
            return
        }

        if (args.name == "BoughtShopItems")
        {
            // Bought items was updated
            args.val.forEach((item_data) => {
                const id = shop_data_map_name_to_id[GetItemName(item_data)];
                const $entry = $(`#SI_${id}`);
                if ($entry && $entry.length > 0)
                {
                    // Update item entry
                    $entry.removeClass('cant-afford');
                    if (!$entry.hasClass('purchased'))
                    {
                        $entry.addClass('purchased');
                        if (!$entry.hasClass('equipped'))
                        {
                            $entry.find('div.buy-equip').text("EQUIP");
                        }
                    }
                }
            });
        }
        else if (args.name == "Money")
        {
            $(`#moneydisplay`).text(`$${(args.val / 100).toFixed(2)}`)
            for (const index in shop_data)
            {
                const item_data = shop_data[index];
                const $entry = $(`#SI_${item_data.id}`);

                if (!$entry.hasClass('purchased') && !$entry.hasClass('equipped'))
                {
                    if (!$entry.hasClass('cant-afford') && args.val < item_data.cost)
                    {
                        $entry.addClass('cant-afford')
                    }
                    else if ($entry.hasClass('cant-afford') && args.val >= item_data.cost)
                    {
                        $entry.removeClass('cant-afford')
                    }
                }
            }

        }
        else if (args.name == "Model")
        {
            args.val = args.val.replace("|", "_").replace(",", "")
            // Player equipped/unequipped a model/outfit (format: MODEL|OUTFITNUMBER)
            for (const index in shop_data)
            {
                const item_data = shop_data[index];

                if (GetItemName(item_data) == args.val)
                {
                    $(`#SI_${item_data.id}`).addClass('equipped')
                    $(`#SI_${item_data.id}`).find('div.buy-equip').text('EQUIPPED')
                }
                else if ($(`#SI_${item_data.id}`).hasClass('equipped'))
                {
                    $(`#SI_${item_data.id}`).removeClass('equipped')
                    $(`#SI_${item_data.id}`).find('div.buy-equip').text('EQUIP')
                }
            }
        }
    }

    // When they click one of the map buttons
    $(document).on("click", "div.shop-entry div.buy-equip", function() 
    {
        if ($(this).parent().hasClass('cant-afford'))
        {
            return;
        }

        if ($(this).parent().hasClass('purchased'))
        {
            // send request to equip the item
            NAPI.CallEvent('lobby/shop/equip_item', {id: $(this).parent().attr('id').replace("SI_", "")});
        }
        else
        {
            // send request to buy the item
            NAPI.CallEvent('lobby/shop/buy_item', {id: $(this).parent().attr('id').replace("SI_", "")});
        }
    })

    // Set section to lobby
    SwitchSection("LOBBY")

    // When they click on the JOIN GAME button to join the already going game
    $(document).on("click", "div.button.clicktojoin", function() 
    {
        NAPI.CallEvent('lobby/joinexistinggame');
    })

    $(document).on("click", "div.button.quit-game", function() 
    {
        invokeNative("exit", "")
    })

    // When they click one of the section buttons, change section
    $(document).on("click", "div.title-entry", function() 
    {
        if (!$(this).hasClass("selected"))
        {
            $('div.title-entry').removeClass('selected')
            $(this).addClass('selected')
            SwitchSection($(this).attr('id'))
        }
    })

    // When they click one of the map buttons
    $(document).on("click", "div.map-entry", function() 
    {
        if (!$(this).hasClass("selected"))
        {
            $("div.map-entry").removeClass("selected")
            $(this).addClass("selected")
            SelectMap($(this).find('div.title').text())
        }
    })

    
    // When they click a difficulty
    $(document).on("click", "div.map-difficulty li", function() 
    {
        const $elem_title = $('#dropdown_title')
        $elem_title.removeClass('easy').removeClass('medium').removeClass('hard').removeClass('gunslinger')
        $elem_title.addClass($(this).text())
    })

    // When they click to join a map
    $(document).on("click", "div.button.map-join", function() 
    {
        if (button_press_timeout != null) {return;}
        if ($(this).hasClass('selected'))
        {
            $(this).removeClass('selected')
            $(this).text('join')
        }
        else
        {
            $(this).addClass('selected')
            $(this).text('leave')
        }
        
        UpdateReadyButtonVisibility()
        JoinLeaveButton($(this).hasClass('selected') || $(this).hasClass('switch'))

        button_press_timeout = setTimeout(() => {
            button_press_timeout = null;
        }, 200);
    })

    let button_press_timeout = null

    // When they click to ready up
    $(document).on("click", "div.button.map-ready", function() 
    {
        if (button_press_timeout != null) {return;}
        if (!$('div.button.map-join').hasClass('selected')) {return;}

        if ($(this).hasClass('selected'))
        {
            $(this).removeClass('selected')
        }
        else
        {
            $(this).addClass('selected')
        }
        ReadyUpButton($(this).hasClass('selected'))
        
        button_press_timeout = setTimeout(() => {
            button_press_timeout = null;
        }, 200);
    })


    $('.dropdown').click(function () {
        $(this).attr('tabindex', 1).focus();
        $(this).toggleClass('active');
        $(this).find('.dropdown-menu').slideToggle(300);
    });
    $('.dropdown').focusout(function () {
        $(this).removeClass('active');
        $(this).find('.dropdown-menu').slideUp(300);
    });
    $('.dropdown .dropdown-menu li').click(function () {
        $(this).parents('.dropdown').find('span').text($(this).text());
        $(this).parents('.dropdown').find('input').attr('value', $(this).attr('id'));
        selected_difficulty = $(this).attr('id')

        let $difficulty = $map_details.find('div.difficulty')
        ClearDifficultyClass($difficulty)
        $difficulty.addClass(selected_difficulty)
        $difficulty.text(selected_difficulty)
        
        GenerateLargePlayerAvatarCircles(selected_map)

        $difficulty = $map_image.find('div.difficulty')
        ClearDifficultyClass($difficulty)
        $difficulty.addClass(selected_difficulty)
        $difficulty.text(selected_difficulty)

        UpdateJoinedAndReadyButtons()
    });

    NAPI.Subscribe('KeyDown', function(key, event)
    {
        if (key == 27) // Escape
        {
            NAPI.CallEvent('lobby/esc');
        }
    })

    NAPI.Subscribe('lobby/queue/sync/full', function(args)
    {
        FullQueueSync(args);
    })

    NAPI.Subscribe('lobby/map/sync/full', function(args)
    {
        FullMapSync(args);
        $('body').show();
    })
    
    NAPI.Subscribe('lobby/queue/sync/single', function(args)
    {
        SingleQueueSync(args);
    })
    
    NAPI.Subscribe('lobby/players/sync/full', function(args)
    {
        $players_container.empty()
        FullPlayersSync(args)
    })
    
    NAPI.Subscribe('lobby/players/sync/single', function(args)
    {
        SinglePlayerSync(args);
    })
    
    NAPI.Subscribe('lobby/queue/sync/countdown', function(args)
    {
        CountdownSync(args);
    })
    
    NAPI.Subscribe('lobby/queue/sync/game', function(args)
    {
        QueueGameSync(args);
    })
    
    NAPI.Subscribe('lobby/shop/sync/shop_items', function(args)
    {
        LoadShopItems(args);
    })
    
    NAPI.Subscribe('lobby/shop/sync/network_val_changed', function(args)
    {
        ShopNetworkValChanged(args);
    })
    
    NAPI.Subscribe('Hide', function()
    {
        music.pause();
    })
    
    NAPI.Subscribe('Show', function()
    {
        music.play();
    })

    NAPI.CallEvent('lobby/ready');
})