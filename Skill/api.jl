#
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
        set_config_prefix(device)
        command = get_config(CONFIG_COMMAND)

        time_strings = get_config(CONFIG_TIMES, multiple=true)
        times = [Dates.Time(t) for t in time_strings]

        day_abbrs = get_config(CONFIG_DAYS, multiple=true)
        days_of_week = mk_days_of_week(day_abbrs)

        reset_config_prefix()

        # schedule device for all days:
        #
        exec_day = start_date
        while exec_day <= end_date
            for exec_time in times
                # schedule device for day:
                #
                if Dates.dayofweek(exec_day) in days_of_week
                    publish_one_schedule(device, command, exec_time, exec_day)
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