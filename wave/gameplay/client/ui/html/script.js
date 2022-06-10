$(document).ready(function() 
{
    $('#big-round').hide();
    $('div.spectating-container').hide();
    $('div.icon').remove();
    $('div.out-of-bounds-container').hide();
    $('div.powerup').remove();
    $('div.survive-until-container').hide();
    $('div.boss-container').hide();

    var survive_until_intervals = [];

    // So we can preview in chrome but not mess up ingame
    if (typeof(NAPI) == 'undefined')
    {
        NAPI = {Subscribe: function(){}}
    }

    function FormatSurviveUntilTime(time)
    {
        let seconds = Math.floor((time / 1000) % 60)
        if (seconds < 10) {seconds = `0${seconds}`;}
        return `${Math.floor(time / 1000 / 60)}:${seconds}`
    }

    NAPI.Subscribe('gameplayui/boss/show', function(args)
    {
        $('div.boss-container div.boss-title').text(args.text);
        $('div.boss-container div.boss-healthbar-inner').css(`width`, "100%");
        $('div.boss-container').show();
    })

    NAPI.Subscribe('gameplayui/boss/update', function(args)
    {
        $('div.boss-container div.boss-healthbar-inner').css(`width`, `${args.percent}%`);
    })

    NAPI.Subscribe('gameplayui/boss/hide', function(args)
    {
        $('div.boss-container').hide();
        $('div.boss-container div.boss-healthbar-inner').css(`width`, "100%");
    })

    NAPI.Subscribe('gameplayui/survive-until/show', function(args)
    {
        // args.time in ms
        let time = 1000 * args.time;
        $('div.survive-until-container div.survive-until-time').text(FormatSurviveUntilTime(time))
        $('div.survive-until-container svg.progress circle.fill').css('transition', `none`);
        $('div.survive-until-container svg.progress circle.fill').css('stroke-dashoffset', `0%`);

        setTimeout(() => {
            $('div.survive-until-container svg.progress circle.fill').css('transition', `stroke-dashoffset ${Math.ceil(time / 1000)}s linear`)

            setTimeout(() => {
                $('div.survive-until-container svg.progress circle.fill').css('stroke-dashoffset', `314%`);
            }, 100);
        }, 100);

        $('div.survive-until-container').show();
        
        
        var interval = setInterval(() => {
            time -= 1000;
            $('div.survive-until-container div.survive-until-time').text(FormatSurviveUntilTime(time))
            
            if (time <= 0)
            {
                clearInterval(interval);
                // Don't hide because we will let the gameplay logic hide it for us
            }
        }, 1000);

        survive_until_intervals.push(interval);
    })

    NAPI.Subscribe('gameplayui/survive-until/hide', function(args)
    {
        $('div.survive-until-container').hide();
        for (i = 0; i < survive_until_intervals.length; i++) { 
            clearInterval(survive_until_intervals[i]);
        }

        survive_until_intervals.length = 0;
    })

    function AddPowerup(args)
    {   
        if ($(`#powerup_${args.type}`).length > 0)
        {
            $(`#powerup_${args.type}`).remove();
        }

        const $elem = $(`
        <div class='powerup' id='powerup_${args.type}'>
            <svg class='progress'>
                <circle class='background'></circle>
                <circle class='fill'></circle>
            </svg>
            <img class='powerup-img' src='imgs/powerup_${args.type}.png'></img>
        </div>`)

        if (args.key != undefined)
        {
            $elem.append(`<div class='powerup-key text'>${args.key}</div>`);
            if (args.charges != undefined)
            {
                $elem.append(`<div class='powerup-charges text'>${args.charges}</div>`);
            }
        }

        if (args.duration != undefined)
        {
            $elem.find('svg.progress circle.fill').css('transition', `stroke-dashoffset ${args.duration}s linear`);
            
            setTimeout(() => {
                $elem.find('svg.progress circle.fill').css('stroke-dashoffset', `314%`);
            }, 100);
        }

        // Used for armor, progress is 0-1, ex 0.8 is first armor upgrade
        if (args.progress != undefined)
        {
            $elem.find('svg.progress circle.fill').css('transition', `stroke-dashoffset 0.2s ease-in-out`);
            $elem.find('svg.progress circle.fill').css('stroke-dashoffset', `${314 * (1 - args.progress)}%`);
        }

        $('div.powerups-container').append($elem);
    }
    
    NAPI.Subscribe('gameplayui/screenicon/create', function(args)
    {
        if (args.icon == "cross")
        {
            const $elem = $(`<div class='icon ${args.icon}' id='I_${args.id}'></div>`);
            $elem.append($(`<img class='icon' src="imgs/${args.icon}.png" />`));
            $elem.append($(`<div class='healthbar'><div class='healthbar-inner'></div></div>`))
            $('body').append($elem);
            
            if (!args.is_localplayer)
            {
                const audio = new Audio('downed.ogg');
                audio.volume = 0.25;
                audio.play();
            }
        }
        else
        {
            $('body').append(
                $(`<div class='icon ${args.icon}' id='I_${args.id}'><img class='icon' src="imgs/${args.icon}.png" /></div>`))
        }
    })
    
    NAPI.Subscribe('gameplayui/powerup/add', function(args)
    {
        AddPowerup(args);
    })

    const activate_queue = [];
    let activate_timeout = null;

    function ActivatePowerup()
    {
        if (activate_timeout == null && activate_queue.length > 0)
        {
            ShowActivatePowerup(activate_queue.shift());
        }
    }

    function ShowActivatePowerup(name)
    {
        const audio = new Audio('activate_powerup.ogg');
        audio.volume = 0.5;
        audio.play();

        $('div.powerup-activate-title').text(name);
        $('div.powerup-activate-container').css('animation', '0.5s ease-in-out show-powerup');
        $('div.powerup-activate-container').show();
        activate_timeout = setTimeout(() => {
            $('div.powerup-activate-container').css('animation', '1s ease-in-out powerup-grow-shrink infinite');
            activate_timeout = setTimeout(() => {
                $('div.powerup-activate-container').css('animation', '0.5s ease-in-out hide-powerup');
                activate_timeout = setTimeout(() => {
                    $('div.powerup-activate-container').hide();
                    activate_timeout = null;
                    ActivatePowerup();
                }, 500);
            }, 4000);
        }, 500);
    }

    NAPI.Subscribe('gameplayui/powerup/activate', function(args)
    {
        activate_queue.push(args.name);
        ActivatePowerup();
    })

    NAPI.Subscribe('gameplayui/powerup/modify', function(args)
    {
        if ($(`#powerup_${args.type}`).find('div.powerup-charges'))
        {
            $(`#powerup_${args.type}`).find('div.powerup-charges').text(args.charges)
        }
        
        if (args.progress)
        {
            $(`#powerup_${args.type}`).find('svg.progress circle.fill').css('stroke-dashoffset', `${314 * (1 - args.progress)}%`);
        }

        if (args.charges == 0)
        {
            $(`#powerup_${args.type}`).remove();
        }
    })
    
    NAPI.Subscribe('gameplayui/outofbounds/show', function(args)
    {
        $('div.out-of-bounds-container').text(args.text)
        $('div.out-of-bounds-container').show()
    })
    
    NAPI.Subscribe('gameplayui/outofbounds/hide', function(args)
    {
        $('div.out-of-bounds-container').hide()
    })
    
    NAPI.Subscribe('gameplayui/screenicon/show', function(args)
    {
        $(`#I_${args.id}`).css('opacity', '1')
    })
    
    NAPI.Subscribe('gameplayui/screenicon/hide', function(args)
    {
        $(`#I_${args.id}`).css('opacity', '0')
    })
    
    NAPI.Subscribe('gameplayui/screenicon/update', function(args)
    {
        args.pos.x = args.pos.x.toFixed(4);
        args.pos.y = args.pos.y.toFixed(4);
        $(`#I_${args.id}`).css('top', `${args.pos.y * 100}%`);
        $(`#I_${args.id}`).css('left', `${args.pos.x * 100}%`);
    })
    
    NAPI.Subscribe('gameplayui/screenicon/updateplayerhealth', function(args)
    {
        $('div.player-healthbar-inner').css('height', `${args.health}%`);
    })
    
    NAPI.Subscribe('gameplayui/screenicon/updatehealth', function(args)
    {
        $(`#I_${args.id}`).find('div.healthbar-inner').css('width', `${args.health}%`);
    })
    
    NAPI.Subscribe('gameplayui/spectate/show', function(args)
    {
        $('div.spectating-container').text(`Spectating: ${args.name}`);
        $('div.spectating-container').show();
        $('div.player-healthbar').hide();
    })
    
    NAPI.Subscribe('gameplayui/spectate/hide', function(args)
    {
        $('div.spectating-container').hide();
        $('div.player-healthbar').show();
    })
    
    NAPI.Subscribe('gameplayui/game/difficulty', function(args)
    {
        $('#difficulty').removeClass('easy').removeClass('medium').removeClass('hard').removeClass('gunslinger')
        $('#difficulty').addClass(args.difficulty)
        $('#difficulty').text(args.difficulty)
    })
    
    NAPI.Subscribe('gameplayui/purchase/sfx', function(args)
    {
        const audio = new Audio('purchase.ogg');
        audio.volume = 0.25;
        audio.play();
    })
    
    NAPI.Subscribe('gameplayui/screenicon/remove', function(args)
    {
        $(`#I_${args.id}`).remove();
    })
    
    NAPI.Subscribe('gameplayui/update_ammo', function(args)
    {
        UpdateAmmo(args);
    })
    
    NAPI.Subscribe('gameplayui/update_points', function(args)
    {
        UpdatePoints(args);
    })
    
    NAPI.Subscribe('gameplayui/update_round', function(args)
    {
        UpdateRound(args);
    })
    
    function UpdateAmmo(data)
    {
        if (data.clip != null)
        {
            $('#clip').text(data.clip)
        }

        if (data.reserve != null)
        {
            $('#reserve').text(data.reserve)
        }
    }

    function UpdatePoints(data)
    {
        if (data.points != null)
        {
            $('#points').text(`$${(data.points / 100).toFixed(2)}`)
        }
    }

    function UpdateRound(data)
    {
        if (data.round != null)
        {
            $('#round').text(data.round)

            const audio = new Audio('round_change.ogg');
            audio.volume = 0.5;
            audio.play();

            $('#big-round').text(`ROUND ${data.round}`)
            $('#big-round').fadeIn(2000);
            $('div.cinematic-bars-bottom').css('bottom', 0);
            $('div.cinematic-bars-top').css('top', 0);
            setTimeout(() => {
                $('#big-round').fadeOut(1000)
                $('div.cinematic-bars-bottom').css('bottom', '-15vh');
                $('div.cinematic-bars-top').css('top', '-15vh');
            }, 5000);
        }
    }
})