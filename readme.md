

# Installation of Required Softwre (MACOS)


## Install Homebrew

    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"


## Install Csound


### With Homebrew

    brew install csound


### With package manager

<https://csound.com/download.html>


### Check Csound version (6.18) (terminal)

    csound --version


### Test Csound

1.  Save following as csd-test.csd in the same folder

        <CsoundSynthesizer>
        <CsOptions>
        -odac
        </CsOptions>
        <CsInstruments>
        instr 1
         aSin  poscil  0dbfs/4, 440
               out     aSin
        endin
        </CsInstruments>
        <CsScore>
        i 1 0 5
        </CsScore>
        </CsoundSynthesizer>

2.  Test Csound

    You should hear a tone for 5 seconds.
    
        csound csd-test.csd


## Download and Install NodeJS

<https://nodejs.org/dist/v18.12.1/node-v18.12.1.pkg>

(or the latest from <https://nodejs.org> )


## Remote OSC

*If your folder includes remote-osc/client, skip this step*

<https://github.com/serkansevilgen/remote-osc/archive/refs/heads/master.zip>

Extract zip and go to folder client/ and run 

    npm install


# Running software


## Csound

    csound xnpm22.csd

Please keep *settings.csd* file in the same folder


## Remote OSC Client

    cd remote-osc/client
    node client.js ./config.json

The config.json file should include the following

    {
        "serverAddress": "3.125.90.128",
        "serverPort": 8081,
        "clientAddress": "0.0.0.0",
        "clientPort": 1337,
        "appAddress": "127.0.0.1",
        "appPort": 7770
    }


## Web UI

-   Go to link

<http://xnpm22.serkansevilgen.com/>

network: /xnpm22
ID: 0 (0 to 7)
Name: Your name

See "Performance Notes" page
<http://xnpm22.serkansevilgen.com/user-guide.html>


# Performance monitoring and debugging


## You should see the content of the config.json when you start Remote OSC client.


## Whenever a performer sends data you should see it in Remote OSC client terminal like

    {
      address: '/xnpm22',
      args: [
        { type: 'i', value: 5 },
        { type: 's', value: 'note_dur' },
        { type: 'f', value:  13},
        { type: 's', value:  'Serkan Sevilgen}
      ]
    }

The first value is userid (5), the second is the name of the parameter (note\_dur) and its value (13). The last value is your name.


## If you don't see the your actions on the Web Interface reflected at the Remote-OSC display, reload Web UI.

