$(document).ready(function() 
{
    let res_name = NAPI.GetParentResourceName();
    const type_key = 84; // T
    const close_key = 27; // Escape
    const send_key = 13; // Enter
    const open_key = 116; // F5
    let messages = [];
    let new_messages = [];
    let channels = [];
    let channel_switch_timeout;
    let current_channel = null;
    let window_hide_timeout = null;
    let open = true;
    let can_open = true;
    let sound_enabled = true;
    let notify_enabled = true;
    let typing = false;
    let msg_amount = 0;
    let can_send = true;
    let transitioning = false;
    const slide_speed = 200;
    const levels = [];
    const players = []; // Names of people on the server
    let my_name;
    let at_index = 0;
    let switched_channels = false;

    const msg_history = []; // Anything that this player typed in chat, used for up and down arrows
    let msg_history_index = 0;

    FadeOutWindow();
    $("div.tooltip").fadeOut(1);
    $('html').css('pointer-events', 'none');
    $('#input-area').hide();
    
    $('html').css('visibility', 'visible');

    /**
     * Adds a message to the chat window.
     * If the current channel matches the message's channel, the message is displayed.
     *
     * @param {object} obj - Object with all the data of the message
     * @param {string} channel - Channel that the message is going to
     */

    function AddMessage(obj)
    {
        let history = obj.history;

        if (obj.channel == null)
        {
            obj.channel = current_channel;
        }

        if (history == undefined)
        {
            obj.mn = msg_amount;
            obj.html = obj.html.replace(`id="m_">`, `id="m_${obj.mn}">`);
            if (obj.channel == undefined)
            {
                if (obj.name == undefined)
                {
                    obj.channel = (typeof channel != 'undefined') ? channel : current_channel;
                }
                else
                {
                    console.log("Warning: player message was not sent with a channel. Rejecting message.");
                    return;
                }
            }
            obj.mi = messages[obj.channel].length;

            if (obj.msg != undefined)
            {
                if (obj.msg.indexOf(`@"${my_name}"`) > -1)
                {
                    obj.at_me = true;
                }
            }
        }

        if (obj.channel == current_channel)
        {
            let message = document.createElement("div");
            message.className = "message";
            message.id = "d_" + obj.mn;
            message.innerHTML = obj.html;
            $('.message-area').append(message);

            if (obj.msg != undefined)
            {
                $(`#m_${obj.mn}`).text(obj.msg);
            }

            if (obj.name != undefined)
            {
                $(`#d_${obj.mn}>#n_${obj.pid}`).text(obj.name);
            }

            if (obj.style != undefined)
            {
                $(`#d_${obj.mn}`).css('font-style', obj.style);
            }

            if (obj.at_me == true) // If they were @ed
            {
                $(`#d_${obj.mn}`).addClass('atted');
                let html = $(`#m_${obj.mn}`).html();

                let index = html.indexOf(`@"${my_name}"`);
                let last_index = html.indexOf(`"`, index + 2);
                if (index > -1 && last_index > -1)
                {
                    html = html.substring(0, index) + `<b><font style='color:#449BF2'>@`
                        + html.substring(index + 2, last_index) + `</font></b>` // gets rid of quotes
                        + html.substring(last_index + 1, html.length + 1);

                    $(`#m_${obj.mn}`).html(html);
                }
            }
            else // Otherwise, highlight the name blue only
            {
                let html = $(`#m_${obj.mn}`).html();
                let ps = JSON.parse(JSON.stringify(players));

                for (let index_ in ps)
                {
                    const name = players[index_];
                    let index = html.indexOf(`@"${name}"`);
                    let last_index = html.indexOf(`"`, index + 2);

                    if (index > -1 && last_index > -1)
                    {
                        html = html.substring(0, index) + `<b><font style='color:#449BF2'>@`
                            + html.substring(index + 2, last_index) + `</font></b>` // gets rid of quotes
                            + html.substring(last_index + 1, html.length + 1);

                        $(`#m_${obj.mn}`).html(html);
                    }
                }

            }

            
            if (obj.everyone && !obj.at_me)
            {
                $(`#d_${obj.mn}`).addClass('atted');
                let html = $(`#m_${obj.mn}`).html();
                html = html.replace(`@everyone`, `<b><font style='color:#449BF2'>@everyone</font></b>`);
                $(`#m_${obj.mn}`).html(html);
            }

            $('.message-area').stop();

            if (!switched_channels)
            {
                $('.message-area').animate({
                    scrollTop: $('.message-area')[0].scrollHeight
                }, 1000, function() 
                {
                    
                });
            }
            else
            {
                $('.message-area').scrollTop($('.message-area')[0].scrollHeight);
            }


            $('#d_' + obj.mn).hide().fadeIn(250);

            if ($(".message-area .message").length > 100)
            {
                setTimeout(() => 
                {
                    $(".message-area .message").first().remove();
                    messages[obj.channel].splice(0,1);
                }, 1000);
            }

        }

        CheckAdditionalArguments(obj);

        if (history == undefined)
        {
            obj.history = true;
            messages[obj.channel].push(obj);
        }

        // If there is a new message on a different channel, create an icon
        if (current_channel != obj.channel)
        {
            if (!$('#ci_' + obj.channel).length)
            {
                /*let container = document.createElement("div");
                container.className = "new-icon";
                container.id = "ci_" + obj.channel;
                $('#ch_' + obj.channel).append(container);

                // TODO make a custom circle with a ! inside it
                let icon = document.createElement("i");
                icon.className = "fa fa-exclamation-circle";
                icon.style.color = "#DBDBDB";
                $('#ci_' + obj.channel).append(icon);*/
            }
        }

        msg_amount++;
        StartWindowHideTimeout();
    }
    

    /**
     * Starts a timeout to hide the window after 10 seconds
     */
    function StartWindowHideTimeout()
    {
        if (window_hide_timeout != null)
        {
            clearTimeout(window_hide_timeout);
        }

        if (!open)
        {
            ToggleOpen();
        }

        window_hide_timeout = setTimeout(() => {
            if (open && !typing && !transitioning)
            {
                ToggleOpen();
            }
            
            window_hide_timeout = null;
        }, 15000);
    }

    /**
     * Checks for and applies additional arguments in the chat message, such as timeouts.
     *
     * @param {object} obj - Object with all the data of the message
     */

    function CheckAdditionalArguments(obj)
    {
        if (typeof obj.timeout != 'undefined')
        {
            setTimeout(() => 
            {
                if (current_channel == obj.channel)
                {
                    $('#d_' + obj.mn).hide(1000, function(){$('#d_' + obj.mn).remove();});
                }
                messages[obj.channel].splice(obj.mi,1);
            }, 1000 * obj.timeout);
        }
    }

    /**
     * Creates a new channel in the chat window.
     *
     * @param {string} name - Name of the channel to be created
     */

    function CreateNewChannel(name)
    {
        messages[name] = [];
        channels.push(name);

        let channel = document.createElement("span");
        channel.className = "channel";
        channel.textContent = name;
        channel.id = "ch_" + name;
        $('.channels').append(channel);
        if (current_channel == null)
        {
            ChangeChannel(name);
        }
    }

    /**
     * Changes the currently displayed/selected channel.
     *
     * @param {string} new_channel - Channel that the player is switching to.
     */

    function ChangeChannel(new_channel)
    {
        if (new_channel != current_channel)
        {
            switched_channels = true;
            $('#ch_' + current_channel).removeClass('active');
            current_channel = new_channel;
            $('#ch_' + current_channel).addClass('active');
            $('.message-area').empty();
            $("#input-area").focus();

            let length = messages[current_channel].length;
            for (let i = 0; i < length; i++)
            {
                let obj = messages[current_channel][i];
                AddMessage(obj);
            }

            if ($('#ci_' + current_channel).length > 0)
            {
                $('#ci_' + current_channel).remove();
            }
            switched_channels = false;

        }
    }

    function GetWindowFocus()
    {
        NAPI.GetFocus(window);
        NAPI.GetFocus($("#input-area"));
        setTimeout(() => {
            $("#input-area").focus();
            NAPI.GetFocus($("#input-area"));
        }, 50);
    }

    // Click a channel to change it
    $(".channels").on("click", ".channel", function()
    {
        ChangeChannel($(this).text());
    });

    function OnKeyUp(keycode, e)
    {
        if (keycode == send_key && typing && !transitioning)
        {
            let msg = $("#input-area").val();
            if (msg.length > 0 && can_send && current_channel != null && current_channel != "Log")
            {
                NAPI.CallEvent('chat/submit_message', {msg: msg, channel: current_channel})
                msg_history.splice(0, 0, msg); // Add to message history
                msg_history_index = 0;
            }

            FadeOutWindow();
            $("#input-area").val("");
            $("#input-area").blur();
            $('#input-area').clearQueue();
            $('#input-area').stop();
            $('#input-area').show();
            stack_data = [];
            transitioning = true;

            $('#input-area').hide("slide", { direction: "up" }, slide_speed, function() {
                typing = false;
                transitioning = false;
            });

            NAPI.CallEvent(`chat/input_state`, {state: false});
            $('html').css('pointer-events', 'none');
            $('html').blur();
            can_send = false;
            setTimeout(() => 
            {
                can_send = true;
            }, 250);
            StartWindowHideTimeout();
        }
        else if (keycode == open_key)
        {
            ToggleOpen();
        }
        else if (keycode == close_key && typing && !transitioning)
        {
            transitioning = true;
            $('#input-area').hide("slide", { direction: "up" }, slide_speed, function() {
                typing = false;
                transitioning = false;
            });
            FadeOutWindow();
            $("#input-area").blur();
            $("#input-area").val("");
            $('html').css('pointer-events', 'none');
            $('html').blur();
            NAPI.CallEvent(`chat/input_state`, {state: false});
            StartWindowHideTimeout();
        }
        else if (keycode == type_key && !typing && !transitioning && can_open)
        {
            if (!open)
            {
                ToggleOpen();
            }

            FadeInWindow();
            typing = true;
            transitioning = true;
            $('#input-area').show("slide", { direction: "up" }, slide_speed, function() {
                transitioning = false;
            });
            GetWindowFocus();
            $('html').css('pointer-events', 'auto');
            $("#input-area").val("");
            $("#input-area").select();
            NAPI.CallEvent(`chat/input_state`, {state: true});
        }
        else if (keycode == 9 && open && typing) // tab
        {
            GetWindowFocus();
            let msg = $("#input-area").val();

            // If they are trying to mention someone with @name
            if (msg.indexOf(`@`) > -1)
            {
                const index = msg.indexOf(`@`);
                const name = msg.substring(index + 1, msg.length + 1);

                // If they want to cycle through players
                if (name.startsWith(`"`))
                {
                    const first_index = name.indexOf(`"`);
                    const last_index = name.indexOf(`"`, first_index + 1);

                    at_index += 1;
                    if (at_index > players.length - 1) {at_index = 0;}

                    const at_name = players[at_index];

                    msg = msg.replace(`@"${name.substring(1, name.length)}"`, `@"${at_name}"`);
                    $("#input-area").val(msg);
                }
                else if (name.indexOf(`"`) == -1) // Otherwise they entered part of a name and want to match it to someone
                {
                    let player_name = name.trim().toLowerCase();

                    if (player_name.length == 0)
                    {
                        return;
                    }

                    let searched_name = players.find((n) => n.toLowerCase().indexOf(player_name) > -1);
                    
                    // We got a match
                    if (searched_name && searched_name.length > 1)
                    {
                        msg = msg.substring(0, index) + `@"${searched_name}" `;
                        $("#input-area").val(msg);
                    }

                }

            }

            SetCaretToEnd();
            e.preventDefault();

            return false;
        }
        else if (keycode == 38 && open && typing && msg_history.length > 0) // Up arrow
        {
            $("#input-area").val(msg_history[msg_history_index]);
            SetCaretToEnd();

            msg_history_index = (msg_history_index + 1 >= msg_history.length) ? 0 : msg_history_index + 1;
        }
        else if (keycode == 40 && open && typing && msg_history.length > 0) // Down arrow
        {
            $("#input-area").val(msg_history[msg_history_index]);
            SetCaretToEnd();

            msg_history_index = (msg_history_index - 1 < 0) ? msg_history.length - 1 : msg_history_index - 1;
        }

        // Spacebar or shift, prevents scrolling
        if (keycode === 32 || keycode == 16) 
        {
            e.preventDefault();
            return false;
        }

    };

    function SetCaretToEnd()
    {
        GetWindowFocus();
        if($("#input-area").createTextRange)
        {
            const range = $("#input-area").createTextRange();
            range.move('character', $("#input-area").val().length - 1);
            range.select();
        }
        else 
        {
            if($("#input-area").selectionStart) 
            {
                $("#input-area").focus();
                $("#input-area").setSelectionRange($("#input-area").val().length - 1, $("#input-area").val().length - 1);
            }
            else
            {
                $("#input-area").focus();
            } 
        }
    }

    function ToggleOpen()
    {
        open = !open;
        $('html').css('pointer-events', 'none');
        $('html').blur();
        if (open)
        {
            $('.window').clearQueue();
            $('.window').stop();
            $('.window').css('visibility', 'visible');
            $('.window').fadeIn("fast");
            $("#input-area").val("");
            $('#input-area').hide();
        }
        else
        {
            FadeOutWindow();
            typing = false;
            $('.window').clearQueue();
            $('.window').stop();
            $('.window').fadeOut("fast");
            $("#input-area").val("");
            $('#input-area').hide();
            stack_data = [];
        }

        //NAPI.CallEvent(`chat/input_state`, {state: false});
    }

    function FadeOutWindow()
    {
        $(`::-webkit-scrollbar`).stop();
        $(`::-webkit-scrollbar`).fadeOut(200);
        $(`div.message-area`).css({
            'border-color': 'rgba(255, 255, 255, 0)',
            'background-color': 'rgba(0, 0, 0, 0.0)',
        });
        $(`div.channels`).stop();
        $(`div.channels`).fadeOut(200);
    }

    function FadeInWindow()
    {
        $(`::-webkit-scrollbar`).stop();
        $(`::-webkit-scrollbar`).fadeIn(200);
        $(`div.message-area`).css({
            'border-color': 'rgba(255, 255, 255, 0.4)',
            'background-color': 'rgba(0, 0, 0, 0.2)',
        });
        $(`div.channels`).stop();
        $(`div.channels`).fadeIn(200);
    }

    function ClearChat()
    {
        $(".message").each(function(index) 
        {
            $(this).hide(1000, function() {$(this).remove();});
        });

        messages[current_channel] = [];
        AddMessage({html: "<b>Chat Cleared.</b>", timeout: 5}, 224, 210, 114);
    }

    function InitConfig(config)
    {
        config.default_channels.forEach((name) => 
        {
            if (typeof messages[name] == 'undefined')
            {
                CreateNewChannel(name);
            }
        });
    }

    function PreventScrolling(keycode, e)
    {
        // Spacebar or shift, prevents scrolling
        if (keycode === 32 || keycode == 16) 
        {
            e.preventDefault();
            return false;
        }
    }

    NAPI.Subscribe('chat/toggle_enabled', function(args)
    {
        can_open = args.can_open;
    })

    NAPI.Subscribe('chat/init_config', function(args)
    {
        InitConfig(args);
    })

    NAPI.Subscribe('chat/add_message', function(args)
    {
        AddMessage(args);
    })

    NAPI.Subscribe('chat/clear_chat', function()
    {
        ClearChat();
    })

    NAPI.Subscribe('chat/toggle_open', function()
    {
        ToggleOpen();
    })

    NAPI.Subscribe('chat/store_name', function(args)
    {
        my_name = args.name;
    })

    NAPI.Subscribe('KeyUp', function(args)
    {
        return OnKeyUp(args.key, args.event);
    })

    NAPI.Subscribe('KeyDown', function(args)
    {
        return PreventScrolling(args.key, args.event)
    })

    NAPI.Subscribe('KeyPress', function(args)
    {
        return PreventScrolling(args.key, args.event)
    })
            
    NAPI.Subscribe('chat/remove_player', function(args)
    {
        const name = args.name;
        if (players.indexOf(name) > -1) {players.splice(players.indexOf(name), 1);}
    })

    NAPI.Subscribe('chat/start_typing', function()
    {
        OnKeyUp(type_key);
    })

    NAPI.Subscribe('chat/add_player', function(args)
    {
        if (!players.includes(args.name))
        {
            players.push(args.name);
        }
    })

    NAPI.CallEvent(`chat/ui_ready`);
})
