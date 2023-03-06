#
# actions called by the main callback()
# provide one function for each intent, defined in the Snips/Rhasspy
# console.
#
# ... and link the function with the intent name as shown in config.jl
#
# The functions will be called by the main callback function with
# 2 arguments:
# + MQTT-Topic as String
# + MQTT-Payload (The JSON part) as a nested dictionary, with all keys
#   as Symbols (Julia-style).
#




"""
    Susi_WeeklySchedule_action(topic, payload)

Generated dummy action for the intent Susi:WeeklySchedule.
This function will be executed when the intent is recognized.
"""
function Susi_WeeklySchedule_action(topic, payload)

    print_log("action Susi_WeeklySchedule_action() started.")

    # get slots:
    #
    #start_day = tryparse(Int, extract_slot_value(SLOT_DAY_FROM, payload))
    start_day = tryparse(Int, extract_slot_value(SLOT_DAY_FROM, payload, default=""))
    start_month = tryparse(Int, extract_slot_value(SLOT_MONTH_FROM, payload, default=""))
    start_year = tryparse(Int, extract_slot_value(SLOT_YEAR_FROM, payload, default=""))
    
    end_day = tryparse(Int, extract_slot_value(SLOT_DAY_TO, payload, default=""))
    end_month = tryparse(Int, extract_slot_value(SLOT_MONTH_TO, payload, default=""))
    end_year = tryparse(Int, extract_slot_value(SLOT_YEAR_TO, payload, default=""))
 
    profile = extract_slot_value(SLOT_PROFILE, payload, default="summer")

    # fix missing end info:
    # end day is essetial:
    #
    if isnothing(end_day) 
        publish_end_session(:no_dates, :say_again)
        return true

    elseif isnothing(end_year) && isnothing(end_month) # && !isnothing(end_day)
        end_date = Dates.Date(Dates.year(Dates.today()), Dates.month(Dates.today()), end_day) |> next_month()
   
    elseif isnothing(end_year) 
        end_date = Dates.Date(Dates.year(Dates.today()), end_month, end_day) |> next_year()
    end
    
    # fix missing start info:
    #
    if isnothing(start_year) 
        start_year = end_year
    end
    if isnothing(start_month) 
        start_month = end_month
    end
    if isnothing(start_day) 
        start_day = Dates.day(Dates.today())
    end

    start_date = Dates.Date(start_year, start_month, start_day)
    end_date = Dates.Date(end_year, end_month, end_day)

    publish_say(:i_will_schedule, Symbol(profile), :from, 
            readable_date(start_date), 
        :to, readable_date(end_date))

    do_schedule(start_date, end_date, profile)

    publish_end_session(:end_say)
println("bye")
    return true
end




"""
    Susi_DeleteSchedule_action(topic, payload)

Generated dummy action for the intent Susi:DeleteSchedule.
This function will be executed when the intent is recognized.
"""
function Susi_DeleteSchedule_action(topic, payload)

    print_log("action Susi_DeleteSchedule_action() started.")
    publish_say(:skill_echo, get_intent(payload))

    if ask_yes_or_no(:ask_echo_slots)
publish_say(:no_slot)
    else   # ask returns false
        # do nothing
    end

    publish_end_session(:end_say)
    return true
end
