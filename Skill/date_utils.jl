const EASTER_SUNDAY = Dict(2020 => Dates.Date(2020, 4, 12),
                    2021 => Dates.Date(2021, 4, 4),
                    2022 => Dates.Date(2022, 4, 17),
                    2023 => Dates.Date(2023, 4, 9),
                    2024 => Dates.Date(2024, 3, 31),
                    2025 => Dates.Date(2025, 4, 20),
                    2026 => Dates.Date(2026, 4, 5),
                    2027 => Dates.Date(2027, 3, 28),
                    2028 => Dates.Date(2028, 4, 16),
                    2029 => Dates.Date(2029, 4, 1),
                    2030 => Dates.Date(2030, 4, 21),
                    2031 => Dates.Date(2031, 4, 13),
                    2032 => Dates.Date(2032, 3, 28))
const EASTER_MONDAY = Dict(2020 => Dates.Date(2020, 4, 13),
                    2021 => Dates.Date(2021, 4, 5),
                    2022 => Dates.Date(2022, 4, 18),
                    2023 => Dates.Date(2023, 4, 10),
                    2024 => Dates.Date(2024, 4, 1),
                    2025 => Dates.Date(2025, 4, 21),
                    2026 => Dates.Date(2026, 4, 6),
                    2027 => Dates.Date(2027, 3, 29),
                    2028 => Dates.Date(2028, 4, 17),
                    2029 => Dates.Date(2029, 4, 2),
                    2030 => Dates.Date(2030, 4, 22),
                    2031 => Dates.Date(2031, 4, 14),
                    2032 => Dates.Date(2032, 3, 29))
const GOOD_FRIDAY = Dict(2020 => Dates.Date(2020, 4, 10),
                    2021 => Dates.Date(2021, 4, 2),
                    2022 => Dates.Date(2022, 4, 15),
                    2023 => Dates.Date(2023, 4, 7),
                    2024 => Dates.Date(2024, 3, 29),
                    2025 => Dates.Date(2025, 4, 18),
                    2026 => Dates.Date(2026, 4, 3),
                    2027 => Dates.Date(2027, 3, 26),
                    2028 => Dates.Date(2028, 4, 14),
                    2029 => Dates.Date(2029, 3, 30),
                    2030 => Dates.Date(2030, 4, 19),
                    2031 => Dates.Date(2031, 4, 11),
                    2032 => Dates.Date(2032, 3, 26))
const THANKSGIVING = Dict(2020 => Dates.Date(2020, 11, 26),
                    2021 => Dates.Date(2021, 11, 25),
                    2022 => Dates.Date(2022, 11, 24),
                    2023 => Dates.Date(2023, 11, 23),
                    2024 => Dates.Date(2024, 11, 28),
                    2025 => Dates.Date(2025, 11, 27),
                    2026 => Dates.Date(2026, 11, 26),
                    2027 => Dates.Date(2027, 11, 25),
                    2028 => Dates.Date(2028, 11, 23),
                    2029 => Dates.Date(2029, 11, 22),
                    2030 => Dates.Date(2030, 11, 28),
                    2031 => Dates.Date(2031, 11, 27),
                    2032 => Dates.Date(2032, 11, 25))

NAMED_DAYS_VARIABLE = Dict("easter_sunday" => EASTER_SUNDAY,
                    "easter_monday" => EASTER_MONDAY,
                    "good_friday" => GOOD_FRIDAY,
                    "thanksgiving" => THANKSGIVING)

NAMED_DAYS_FIXED = Dict("xmas_eve" => (12, 24),
                  "xmas1" => (12, 25),
                  "xmas2" => (12, 26),
                  "new_year_eve" => (12, 31),
                  "new_year" => (1, 1),
                  "independence_day" => (7, 4))

WEEKDAYS = ["next_monday", "next_tuesday", "next_wednesday", "next_thursday", 
            "next_friday", "next_saturday", "next_sunday"]
# takes a named day and checks, if it is a valid name of
# a special day, like "christmas" or "new year's day".
# it returns the day and month of the named day, or `nothing`,
# `nothing`, `nothing`.
# If the identified day is in the past, weeks, months or years are 
# added until it is in the future (i.e. after base).
#
function named_day(name; base=Dates.today(), year=nothing)


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

    elseif name in WEEKDAYS
        weekday = findfirst(x -> x == name, WEEKDAYS)
        base_weekday = Dates.dayofweek(base)
        day = base + Dates.Day(weekday - base_weekday)

        # this may be in the future or in the past -> step weeks
        # to find the first possible weekday in the future or today:
        #
        day = step_week(day, base=base)
        return day

    elseif name in keys(NAMED_DAYS_FIXED)
        month, day = NAMED_DAYS_FIXED[name]
        if isnothing(year)
            return next_year_with_date(month, day, base=base)
        else
            return Dates.Date(year, month, day)
        end

    elseif name in keys(NAMED_DAYS_VARIABLE)
        if isnothing(year)
            return next_named_day(NAMED_DAYS_VARIABLE[name], base=base)
        else
            return NAMED_DAYS_VARIABLE[name][year]
        end

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


# get a Dict with year => Date for a named day and returns the
# first date in the future (i.e. >= base):
#
function next_named_day(named_days; base=Dates.today())

    year = Dates.year(base)

    while haskey(named_days, year) && (named_days[year] < base)
        year += 1
    end
    
    if haskey(named_days, year)
        date = named_days[year]
        return date
    else
        return nothing
    end
end