# Evertils

Evertils is a command line utility for interacting with your Evernote account.

## Installation

1. `gem install evertils`
2. `git clone git@github.com:aapis/evertils-config.git ~/.evertils`
3. `mv ~/.evertils/config.dist.yml ~/.evertils/config.yml && nano ~/.config.yml`

Get your Evernote Developer Tokens [here](https://www.evernote.com/Login.action?targetUrl=%2Fapi%2FDeveloperToken.action).

## Logging Specification
See [this document](https://github.com/aapis/evertils/wiki/Logging-Specification) to see how it all gets organized.

## How to Use

|Command|Description|Usage|
|:--------------|:-----------|:-------------|
|generate|Create notes from templates|`evertils generate daily`, `evertils generate morning`, `evertils generate monthly`|
|log|Interact with a note's content|`evertils log message "I am a message"`, `evertils log grep 2223`, `evertils log group`|

## Automation

If you're using OSX > 10.4:

1. Rename `com.evertils.plist.dist` to `com.evertils.plist` and update the ProgramArguments value to point to where the gem lives (i.e. `/Library/Ruby/Gems/2.0.0`).
2. `cp com.evertils.plist /Library/LaunchDaemons`
3. `launchtl load -w /Library/LaunchDaemons/com.evertils.plist`

If using *nix:

1. Configure a cron job.
2. Profit.
