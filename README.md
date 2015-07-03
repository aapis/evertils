# Evertils

Utilities for talking to your Evernote account.  Create notes, generate statistics based on usage, [more to come].

## Installation

1. `gem install evertils`
2. Add `export EVERTILS_TOKEN="token_goes_here"` to your ~/.profile

Get your Evernote Developer Tokens [here](https://www.evernote.com/Login.action?targetUrl=%2Fapi%2FDeveloperToken.action).

## Logging Specification
See [this document](LOGGING_SPECIFICATION.md) to see how it all gets organized.

## How to Use

|Command|Description|Usage|
|:--------------|:-----------|:-------------|
|generate|Create notes based on templates|`evertils generate daily|weekly|monthly`|
|new|Manually create notes|`evertils new note "STUFF"`, `evertils new share_note "STUFF"`, `other task | evertils new share_note --title="Piped data note"`|
|get|Get data from Evernote|`evertils get notebook`|
|convert|Convert your notes to Markdown, then back to ENML|(coming soon)|
