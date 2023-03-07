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

This function will be executed when the intent 
"Susi:WeeklySchedule" is recognized.
"""
function Susi_WeeklySchedule_action(topic, payload)

    print_log("action Susi_WeeklySchedule_action() started.")

    # get slots:
    #
    start_year = start_month = start_day = start_date = nothing
    end_year = end_month = end_day = end_date = nothing

    # make start date:
    #
    start_day = extract_slot_value(SLOT_DAY_FROM, payload, as=String)
    start_date = named_day(start_day)   # nothing if no match!

    if isnothing(start_date)
        start_day = extract_slot_value(SLOT_DAY_FROM, payload, as=Int)
        start_month = extract_slot_value(SLOT_MONTH_FROM, payload, as=Int)
        start_year = extract_slot_value(SLOT_YEAR_FROM, payload, as=Int)
    else
        start_year, start_month, start_day = Dates.yearmonthday(start_date)
    end
    
    # make end date:
    #
    end_day = extract_slot_value(SLOT_DAY_TO, payload, as=String)

    if isnothing(start_date)
        end_date = named_day(end_day, base=Dates.today())   
    else
        end_date = named_day(end_day, base=start_date)   # nothing if no match!
    end

    if isnothing(end_date)
        end_day = extract_slot_value(SLOT_DAY_TO, payload, as=Int)
        end_month = extract_slot_value(SLOT_MONTH_TO, payload, as=Int)
        end_year = extract_slot_value(SLOT_YEAR_TO, payload, as=Int)
    else
        end_year, end_month, end_day = Dates.yearmonthday(end_date)
    end

    return fix_dates_and_run(payload, start_day, start_month, start_year, 
                             end_day, end_month, end_year)
end


"""
    Susi_WeeklyScheduleOne_action(topic, payload)

This function will be executed when the intent 
"Susi:WeeklyScheduleOneDay" is recognized.
"""
function Susi_WeeklyScheduleOneDay_action(topic, payload)

    print_log("action Susi_WeeklyScheduleOneDay_action() started.")

    # get slots:
    #
    start_year = start_month = start_day = start_date = nothing
    end_year = end_month = end_day = end_date = nothing

    # make start date:
    #
    start_day = extract_slot_value(SLOT_DAY, payload, as=String)
    start_date = named_day(start_day)   # nothing if no match!

    if isnothing(start_date)
        start_day = extract_slot_value(SLOT_DAY, payload, as=Int)
        start_month = extract_slot_value(SLOT_MONTH, payload, as=Int)
        start_year = extract_slot_value(SLOT_YEAR, payload, as=Int)
    else
        start_year, start_month, start_day = Dates.yearmonthday(start_date)
    end
    
    # make end date the same as start date:
    #
    end_date = start_date
    end_year, end_month, end_day = start_year, start_month, start_day

    return fix_dates_and_run(payload, start_day, start_month, start_year, 
                             end_day, end_month, end_year)
end

 nd



function fix_dates_and_run(payload, 
                           start_day, start_month, start_year, 
                           end_day, end_month, end_year)

    # fix missing end info:
    #
    # end day is essetial:
    #
    if isnothing(end_day) 
        publish_end_session(:no_dates, :say_again)
        return true
    end

    # if start is ready from slots:
    #
    if all_defined(start_day, start_month, start_year)
        start_date = Dates.Date(start_year, start_month, start_day)

    # if start is completely missing -> use today:
    #
    elseif all_nothing(start_day, start_month, start_year)
        start_date = Dates.today()

    # if start is only day:
    #
    elseif all_defined(start_day) && all_nothing(start_month, start_year)

        if all_defined(end_month, end_year)
            start_date = Dates.Date(end_year, end_month, start_day)
        elseif all_defined(end_month) && all_nothing(end_year)
            start_date = Dates.Date(Dates.year(Dates.today()), 
                         end_month, start_day)
            start_date = step_year(start_date)
        else
            start_date = Dates.Date(Dates.year(Dates.today()), Dates.month(Dates.today()), 
                                    start_day)
            start_date = step_month(start_date)
        end

    # if start is only day and month:
    #
    elseif all_defined(start_day, start_month) && all_nothing(start_year)
        start_date = Dates.Date(Dates.year(Dates.today()), start_month, start_day)
        start_date = step_year(start_date)
    end
    start_day, start_month, start_year = Dates.yearmonthday(start_date)

    println("FIXED start_date: $start_date")
    # if end is ready from slots:
    #
    if all_defined(end_day, end_month, end_year)
        end_date = Dates.Date(end_year, end_month, end_day)

    # if end is only day:
    #
    elseif all_defined(end_day) && all_nothing(end_month, end_year)
        end_date = Dates.Date(start_year, start_month, end_day)
        end_date = step_month(end_date, base=start_date)
    
    # if end is only day and month:
    #
    elseif all_defined(end_day, end_month) && all_nothing(end_year)
        end_date = Dates.Date(start_year, end_month, end_day)
        end_date = step_year(end_date, base=start_date)
    end
    end_year, end_month, end_day = Dates.yearmonthday(end_date)
    println("FIXED end_date: $end_date")


    if end_date < start_date
        publish_end_session(:end_before_start)
        return true
    end

    profile = extract_slot_value(SLOT_PROFILE, payload, default="default")
    if !check_profile(profile)
        publish_end_session(:check_profile)
        return true
    end 

    publish_say(:i_will_schedule, Symbol(profile), :from, 
            readable_date(start_date), 
        :to, readable_date(end_date))

#    do_schedule(start_date, end_date, profile)

    publish_end_session(:end_say)
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
