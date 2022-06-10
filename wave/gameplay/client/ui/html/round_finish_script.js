$(document).ready(function() 
{
    NAPI.Subscribe('gameplayui/gamefinish/show', function(args)
    {
        $('div.round').text(`ROUND ${args.round}`);
        $('div.round-small').css('opacity', '1');
        setTimeout(() => {
            $('div.round').css('opacity', '1');
        }, 1000);
    })

    NAPI.Subscribe('gameplayui/gamefinish/hide', function(args)
    {
        $('div.round-small').css('opacity', '0')
        $('div.round').css('opacity', '0')
    })
})