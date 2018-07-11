# Evertils

Evertils is a command line utility for interacting with your Evernote account.

## Installation

1. `gem install evertils`
2. Add `export EVERTILS_TOKEN="token_goes_here"` to your ~/.profile

Get your Evernote Developer Tokens [here](https://www.evernote.com/Login.action?targetUrl=%2Fapi%2FDeveloperToken.action).

## Logging Specification
See [this document](https://github.com/aapis/evertils/wiki/Logging-Specification) to see how it all gets organized.

## How to Use

|Command|Description|Usage|
|:--------------|:-----------|:-------------|
|generate|Create notes from templates|`evertils generate daily`, `evertils generate morning`, `evertils generate monthly`|
|new|Manually create notes|`evertils new note "STUFF"`, `evertils new share_note "STUFF"`, `other task $PIPE_CHAR$ evertils new share_note --title="Piped data note"`|
|get|Get data from Evernote|`evertils get notebook` (coming soon)|
|convert|Convert your notes to Markdown, then back to ENML|(coming soon)|

## Automation

If you're using OSX > 10.4:

1. Rename `com.evertils.plist.dist` to `com.evertils.plist` and update the ProgramArguments value to point to where the gem lives (i.e. `/Library/Ruby/Gems/2.0.0`).
2. `cp com.evertils.plist /Library/LaunchDaemons`
3. `launchtl load -w /Library/LaunchDaemons/com.evertils.plist`

If using *nix:

1. Configure a cron job.
2. Profit.
