$(document).ready(function() 
{
    const $bg = $('div');

    NAPI.Subscribe('blackscreen/toggle', function(args)
    {
        ToggleBlackScreen(args);
    })

    function ToggleBlackScreen(data)
    {
        if (data.time == 0)
        {
            $bg.css('opacity', data.visible ? '1.0' : '0.0')
        }
        else
        {
            $bg.animate({
                opacity: data.visible ? 1.0 : 0.0,
                duration: data.time
            });
        }
    }
})