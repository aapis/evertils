# Evertils

Utilities for talking to your Evernote account.  Create notes, generate statistics based on usage, [more to come].

## Installation

Clone this repo, then add the following to your `~/.profile`:

```bash
export PATH=$PATH:/path_to_cloned_dir
export EVERTILS_TOKEN="YOUR_EVERNOTE_TOKEN"
alias evertils='evertils.rb'
```

1. Execute `bundle install`
2. Execute `evertils clean logs` to test if everything installed correctly

## Logging Specification
See [this document](LOGGING_SPECIFICATION.md) to see how it all gets organized.

## How to Use

|Command|Description|Usage|
|--------------|-----------|--------------|
|generate|Create notes based on templates|`evertils generate daily|weekly|monthly`|
|clean|Manually cleanup old logs in `./logs/*`|`rbtils clean`|
