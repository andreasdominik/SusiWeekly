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
    # make start date:
    #
    start_day = extract_slot_value(SLOT_DAY_FROM, payload, as=String)
    start_year, start_month, start_day = named_day(start_day)   # nothing if no match!

    if isnothing(start_day)
        start_day = extract_slot_value(SLOT_DAY_FROM, payload, as=Int)
    end
    if isnothing(start_month)
        start_month = extract_slot_value(SLOT_MONTH_FROM, payload, as=Int)
    end
    start_year = extract_slot_value(SLOT_YEAR_FROM, payload, as=Int)
    
    # make start date:
    #
    end_day = extract_slot_value(SLOT_DAY_FROM, payload, as=String)
    end_day, end_month = named_day(end_day)   # nothing if no match!

    if isnothing(end_day)
        end_day = extract_slot_value(SLOT_DAY_FROM, payload, as=Int)
    end
    if isnothing(end_month)
        end_month = extract_slot_value(SLOT_MONTH_FROM, payload, as=Int)
    end

    profile = extract_slot_value(SLOT_PROFILE, payload, default="default")

    print_log("start_day: $start_day")
    print_log("start_month: $start_month")
    print_log("start_year: $start_year")
    print_log("end_day: $end_day")
    print_log("end_month: $end_month")
    print_log("end_year: $end_year")
    print_log("profile: $profile")

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
