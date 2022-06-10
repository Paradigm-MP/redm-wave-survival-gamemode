const fs = require('fs')

for (let i = 1; i <= 15; i++)
{
    let contents = fs.readFileSync('zombies2.oac', 'utf8')
    contents = `${contents}\n
        WaveTrack hit${i}
        {
            Compression PCM
            Headroom 161
            LoopPoint -1
            LoopBegin 0
            LoopEnd 0
            PlayBegin 0
            PlayEnd 0
            Wave zombies\\hit${i}.wav
            AnimClip null
            Events null
            UNKNOWN_23097A2B null
            UNKNOWN_E787895A null
            UNKNOWN_252C20D9 null
        }`
    fs.writeFileSync('zombies2.oac', contents);
}