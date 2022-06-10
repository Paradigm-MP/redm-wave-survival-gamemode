$(document).ready(function() 
{
    function AddTip(data)
    {
        const $tip = $(`<div class='tip'></div>`);
        $tip.append(`<div class='title'>${data.title}</div>`)
        $tip.append(`<div class='description'>${data.description}</div>`)

        $('body').append($tip)
        $tip.animate({'right': '+=100vw'})

        setTimeout(() => {
            $tip.fadeOut(500)
            setTimeout(() => {
                $tip.remove()
            }, 500);
        }, 15000);
    }

    NAPI.Subscribe('tips/add', function(args)
    {
        AddTip(args);
    })

})