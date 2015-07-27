## Daily logs
* Log location: {COMPANY_NAME} Logs/Daily
* Title format: Daily Log [Date - Day of Week]
* Tags should be used to denote important/new items
* Misc tasks
  * update expense report sheet every Friday
  * complete time tracking (Harvest)
  * create next weekly log
  * update next week's meeting notes

## Weekly logs
* Log location: {COMPANY_NAME} Logs/Weekly
* Title format: Weekly Log [Start of Week Date - End of Week Date]
* Link to each daily log and contain a summary of the important items (tags denote important items, use them to determine what the important weekly items are)
* Tagged “week-$WEEK_NUM”

## Monthly logs
* Log location: {COMPANY_NAME} Logs/Monthly
* Title format: Monthly Log [Month - Year]
* Links to each weekly log of that month (table of contents style)
* Tagged “month-$MONTH_NUM"

## Special Tags
* borked - I broke something in production
* interview - interviewed someone or was part of an interview
* meeting - participated in a meeting of some kind

## Log Templates
See [this directory](lib/configs/templates).

## tl;dr

Basic setup in Evernote:

```
- {{COMPANY_NAME}} Logs
  - Daily
  - Weekly
  - Monthly
```

To quickly add notes based on a template dictated by the requirements above:

```shell
evertils generate daily # adds a note to Logs/Daily
evertils generate weekly # adds a note to Logs/Weekly
evertils generate monthly # adds a note to Logs/Monthly
```

Just make sure to update that note every time you do something, otherwise you'll be logging a whole lot of nothing.