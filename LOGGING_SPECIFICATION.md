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
* Weekly goals section included as a constant reminder of what needs to be done this week, also handy for sending to {{BOSS_MAN}} each Monday
* Project updates go under each weekly goal

## Monthly logs
* Log location: {COMPANY_NAME} Logs/Monthly
* Title format: Monthly Log [Month - Year]
* Links to each weekly log of that month (table of contents style)
* Tagged “month-$MONTH_NUM"
* All weekly goals and their completion status (done or not)
* My quarterly goals for this month section (title: Quarterly Goals)

## Quarterly logs
* Log location: {COMPANY_NAME} Logs/Quarterly
* Title format: Quarterly Log [Start Month - End Month Year]
* Links to each monthly and weekly log of that quarter (table of contents style)
* Tagged “q$QUARTER_NUM"
* All quarterly and monthly goals and their completion status (done or not)

## Special Tags
* borked - I broke something in production
* interview - interviewed someone or was part of an interview
* meeting - participated in a meeting of some kind

## Log Templates
See [this directory](lib/configs/templates).