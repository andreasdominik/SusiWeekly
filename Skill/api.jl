
# API function go here, to be called by the
# skill-actions (and trigger-actions):
#

function do_schedule(start_date, end_date, profile)

    # get list of devices for profile:
    #
    devices = get_config(profile, multiple=true)

    # loop devices and days
    #
    for device in devices
        # get device info:
        #
        command = get_config(CONFIG_COMMAND, one_prefix=device)
        time_strings = get_config(CONFIG_TIMES, multiple=true, 
                                  one_prefix=device)
        fuzzy_minutes = 0
        if is_in_config(CONFIG_FUZZY, one_prefix=device)
            val = tryparse(Int, get_config(CONFIG_FUZZY, one_prefix=device))
            if !isnothing(val)
                fuzzy_minutes = val
            end
        end

        times = [Dates.Time(t) for t in time_strings]


        day_abbrs = get_config(CONFIG_DAYS, multiple=true, 
                                  one_prefix=device)
        days_of_week = mk_days_of_week(day_abbrs)

        # schedule device for all days:
        #
        exec_day = start_date
        while exec_day <= end_date
            # schedule device for day:
            #
            for exec_time in times
                # make times fuzzy:
                #
                time += Dates.Minute(rand(-fuzzy_minutes:fuzzy_minutes))

                if Dates.dayofweek(exec_day) in days_of_week
                    publish_one_schedule(device, command, exec_time, exec_day)
                    sleep(1)
                end
            end
            exec_day += Dates.Day(1)
        end
    end
end


# make day-of-week from from vector of 2-digit days
# of week (e.g. ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]
# other days are ignored:
#
function mk_days_of_week(days_abbr)
    
    dows = [findfirst(x -> x == uppercase(day), 
                ["MO", "TU", "WE", "TH", "FR", "SA", "SU"]) 
                for day in days_abbr]
    
    # remove nothing from array:
    #
    dows = filter(x -> !isnothing(x), dows)
    return dows
end


# publish schedule:
#
function publish_one_schedule(device, command, exec_time, exec_day)
    
    exec_datetime = Dates.DateTime(exec_day, exec_time)
    if exec_datetime > Dates.now()
        print_log("publish schedule command for $device at $exec_datetime")

        publish_schedule_command(command, exec_datetime, "SusiWeekly", 
                    sessionID=get_sessionID())
    else
        print_log("ignore schedule command for $device. $exec_datetime is in the past")
    end
    
end



# return true only if all slots are not nothing:
#
all_defined(slots...) = all_not_nothing(slots...)

function all_not_nothing(slots...)
    return all(x->!isnothing(x), slots)
end

function all_nothing(slots...)
    return all(isnothing, slots)
end




function check_profile(profile)

    actions = get_config(profile, multiple=true)
    if isnothing(actions)
        publish_say(:no_profile, :i_heard, profile)
        return false
    
    else
        ok = true
        for a in actions
            if !all([is_in_config("$a:$CONFIG_COMMAND"), 
                     is_in_config("$a:$CONFIG_DAYS"), 
                     is_in_config("$a:$CONFIG_TIMES")])

                publish_say(:incomplete_profile_1, a, :incomplete_profile_2) 
                ok = false
            end
        end
        return ok
    end
end