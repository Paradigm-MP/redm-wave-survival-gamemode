const fs = require('fs')

for (let i = 1; i <= 12; i++)
{
    let contents = fs.readFileSync('dlczombies_sounds.dat54.rel2.xml', 'utf8')
    contents = `${contents}
    <Item type="SoundSet">
        <Name>dlc_zombies_sounds_death${i}</Name>
        <Header>
            <Flags value="0xAAAAAAAA" />
        </Header>
        <Items>
            <Item>
                <ScriptName>zombies_death${i}</ScriptName>
                <SoundName>dlc_zombies_death${i}_mt</SoundName>
            </Item>
        </Items>
    </Item>
`
    fs.writeFileSync('dlczombies_sounds.dat54.rel2.xml', contents);
}