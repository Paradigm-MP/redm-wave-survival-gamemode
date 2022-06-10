$(document).ready(function() 
{
    const elems = 
    {
        "INIT_SESSION_1": {count: 84, idx: 0, weight: 84},
        "INIT_SESSION_2": {count: 48, idx: 0, weight: 48},
        "onDataFileEntry": {count: 9, idx: 0, weight: 30}
    }

    const total_weight = count(elems, "weight");

    const loading_bar = $('div.loader-inside');
    loading_bar.css('width', '0%');
    const background = $('div.bg');
    background.css('filter', 'grayscale(1)');

    function UpdateLoadingBar(done)
    {
        const total_count = count(elems, "count");
        const total_idx = count(elems, "idx");

        const percent = (done) ? 1 : total_idx / total_count;

        loading_bar.css('width', `${percent * 100}%`);
        background.css('filter', `grayscale(${1 - percent})`);
    }

    function count(list, v)
    {
        let cnt = 0;
        for (entry in list)
        {
            cnt += list[entry][v];
        }
        return cnt;
    }

    const handlers = {
        startInitFunctionOrder(data)
        {
            if (elems["INIT_SESSION_1"].idx == 0)
            {
                elems["INIT_SESSION_1"].count = data.count - 1;
            }
            else
            {
                elems["INIT_SESSION_2"].count = data.count - 1;
            }

            UpdateLoadingBar();
        },
    
        initFunctionInvoking(data)
        {
            if (elems["INIT_SESSION_1"].idx < elems["INIT_SESSION_1"].count - 1)
            {
                elems["INIT_SESSION_1"].idx = data.idx;
            }
            else
            {
                elems["INIT_SESSION_2"].idx = data.idx;
            }

            UpdateLoadingBar();
        },
    
        initFunctionInvoked(data)
        {
            //console.log("initFunctionInvoked");
            //console.log(`type: ${data.type} name: ${data.name} idx: ${data.idx} count: ${data.count}`);
        },
    
        endInitFunction(data)
        {
            UpdateLoadingBar(true);
            //console.log("endInitFunction");
            //console.log(`type: ${data.type} name: ${data.name} idx: ${data.idx} count: ${data.count}`);
        },
    
        startDataFileEntries(data)
        {
            //count = data.count;
            //console.log("startDataFileEntries");
            //console.log(`type: ${data.type} name: ${data.name} idx: ${data.idx} count: ${data.count}`);
        },
    
        performMapLoadFunction(data)
        {
            //console.log("performMapLoadFunction");
            //console.log(`type: ${data.type} name: ${data.name} idx: ${data.idx} count: ${data.count}`);
        },
    
        onDataFileEntry(data)
        {
            //elems["onDataFileEntry"].count = data.type;
            //elems["onDataFileEntry"].idx = Math.min(elems["onDataFileEntry"].idx + 1, elems["onDataFileEntry"].count);

            //UpdateLoadingBar();
        },
    
        endDataFileEntries()
        {
            //console.log("endDataFileEntries");
            //console.log(`type: ${data.type} name: ${data.name} idx: ${data.idx} count: ${data.count}`);
        },
    };

    window.addEventListener('message', function(e)
    {
        (handlers[e.data.eventName] || function() {})(e.data);
    });

})