# DO NOT CHANGE THE FOLLOWING 3 LINES UNLESS YOU KNOW
# WHAT YOU ARE DOING!
# set CONTINUE_WO_HOTWORD to true to be able to chain
# commands without need of a hotword in between:
#
const CONTINUE_WO_HOTWORD = false

# set a local const LANG:
#
const LANG = get_language()


# Slots:
# Name of slots to be extracted from intents:
#
const SLOT_DAY = "day"
const SLOT_DAY_FROM = "day_from"
const SLOT_DAY_TO = "day_to"
const SLOT_MONTH = "month"
const SLOT_MONTH_FROM = "month_from"
const SLOT_MONTH_TO = "month_to"
const SLOT_YEAR = "year"
const SLOT_YEAR_FROM = "year_from"
const SLOT_YEAR_TO = "year_to"
const SLOT_PROFILE = "profile"


# name of entries in config.ini:
#
CONFIG_COMMAND = "command"
CONFIG_DAYS = "days"
CONFIG_TIMES = "times"
CONFIG_FUZZY = "fuzzy"

#
# link between actions and intents:
# intent is linked to action::Funktion
#
# Susi.register_intent_action("TEMPLATE_SKILL", TEMPLATE_INTENT_action)
# Susi.register_on_off_action(TEMPLATE_INTENT_action)
register_intent_action("Susi:WeeklySchedule", Susi_WeeklySchedule_action)
register_intent_action("Susi:WeeklyScheduleOneDay", Susi_WeeklyScheduleOneDay_action)
register_intent_action("Susi:DeleteSchedule", Susi_DeleteSchedule_action)
register_intent_action("Susi:DeleteScheduleToday", Susi_DeleteScheduleToday_action)
