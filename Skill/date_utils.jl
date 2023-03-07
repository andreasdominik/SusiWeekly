# takes a named day and checks, if it is a valid name of
# a special day, like "christmas" or "new year's day".
# it returns the day and month of the named day, or `nothing`,
# `nothing`, `nothing`.
# If the identified day is in the past, weeks, months or years are 
# added until it is in the future (i.e. after base).
#
function named_day(name; base=Dates.today())

    weekdays = ["monday", "tuesday", "wednesday", "thursday", 
                "friday", "saturday", "sunday"]

    if isnothing(name) || !(name isa AbstractString)
        return nothing
    end

    if name == "today"
        return Dates.today()

    elseif name == "tomorrow"
        return Dates.today() + Dates.Day(1)

    elseif name == "day_after"
        return Dates.today() + Dates.Day(2)

    elseif name == "yesterday"
        return Dates.today() # no programming in the past!  - Dates.Day(1)

    elseif name in weekdays
        weekday = findfirst(x -> x == name, weekdays)
        base_weekday = Dates.dayofweek(base)
        day = Dates.today() + Dates.Day(weekday - base_weekday)

        # this may be in the future or in the past -> step weeks
        # to find the first possible weekday in theftutre or today:
        #
        day = step_week(day, base=base)
        return day

    elseif name == "xmas_eve"
        return next_year_with_date(12, 24, base=base)

    elseif name == "xmas1"
        return next_year_with_date(12, 25, base=base)

    elseif name == "xmas2"
        return next_year_with_date(12, 26, base=base)

    elseif name == "new_year_eve"
        return next_year_with_date(12, 31, base=base)

    elseif name == "new_year"
        return next_year_with_date(1, 1, base=base)
    
    else
        return nothing
    end
end


    function step_week(date; base=Dates.today())

        return step_date(date, base; step=7, unit=Dates.Day)
    end

    function step_month(date; base=Dates.today())

        return step_date(date, base; step=1, unit=Dates.Month)
    end

    function step_year(date; base=Dates.today())

        return step_date(date, base; step=1, unit=Dates.Year)
    end
        
    # step a date from 'date' in steps of 'step' and units of 'unit'
    # until the date is greater or equal to 'base':
    #
    function step_date(date, base; step=1, unit=Dates.Day)

        return Dates.tonext(d->d>=base, date, step=unit(step), same=true)
    end



    # returns a date-object with the next valid date for the 
    # day/month given.
    # the returned date is >= base.
    #
    function next_year_with_date(month, day; base=Dates.today())

        this_year = Dates.year(base)
        day = Dates.Date(this_year, month, day)
        day = step_year(day, base=base)
        return day
    end
