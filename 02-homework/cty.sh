#!/bin/bash

IFS=';'


# Function that returns found entry by biggest match of radio call string prefix satisfying both 1st and 2nd criteria
# If second argument is passed returns the largest prefix that match which is used afterwards in get_zones() function
get_radio_call_sign(){
    for (( i=${#1}; i!=0; i-- )); do
        longest_match="${1:0:$i}"
        entry=$(egrep "[ \,\=]{1}$longest_match[ \(\[\;]{1}" $data)
        if [[ $# -eq 2 ]]; then
            [ "$entry" != "" ] && echo $longest_match && break
        else
            [ "$entry" != "" ] && echo $entry && break
        fi
    done
}

# Haversine formula used to calculate the distance between given coordinates for latitude and longtitude for both signs
# https://en.wikipedia.org/wiki/Haversine_formula 
haversine(){
    pi=$(echo "4*a(1)" | bc -l)
    
    # Convert to radians, bc -l command calculates trigonometric functions with given x in radians
    lat1=$(echo "scale=16; ($1) * $pi / 180.0" | bc -l)
    lon1=$(echo "scale=16; ($2) * $pi / 180.0" | bc -l)
    lat2=$(echo "scale=16; ($3) * $pi / 180.0" | bc -l) 
    lon2=$(echo "scale=16; ($4) * $pi / 180.0" | bc -l) 

    dlat=$(echo "$lat2 - $lat1" | bc) 
    dlon=$(echo "$lon2 - $lon1" | bc) 
    
    # Haversine formula
    formula=$(echo "s($dlat / 2)^2 + c($lat1) * c($lat2) * (s($dlon / 2)^2 )" | bc -l)
    
    radius=6371

    # Calculate arcsin using builtin arctan command (bc -l - math library) 
    # arcsin(x)=arctan(x/sqrt(1-x^2))
    arcsin=$(echo "a(sqrt($formula) / sqrt(1 - $formula))" | bc -l)

    echo $(echo "2 * $radius * $arcsin " | bc) | awk '{print int($1+0.5)}'
}


# Function that prints the country for matching radio call entry found in the input file
get_country(){
    echo $(awk -F',' '{print $2}' <(get_radio_call_sign $radio_call_1))
}

# Function that prints the disctance in kilometers between given 2 radio calls using haversine()
get_distance(){
    entry_1=$(get_radio_call_sign $radio_call_1)
    entry_2=$(get_radio_call_sign $radio_call_2)
    latitude_1=$(awk -F',' '{print $7}' <(echo $entry_1))
    longtitude_1=$(awk -F',' '{print $8}' <(echo $entry_1))
    latitude_2=$(awk -F',' '{print $7}' <(echo $entry_2))
    longtitude_2=$(awk -F',' '{print $8}' <(echo $entry_2))

    haversine $latitude_1 $longtitude_1 $latitude_2 $longtitude_2
}


# Function that prints the zones for matching radio call entry found in the input file
get_zones(){
    entry=$(get_radio_call_sign $radio_call_1)
    match=$(get_radio_call_sign $radio_call_1 match)

    # Assing to variables found WAZ and ITU zones
    WAZ=$(cut -d, -f5 <(echo $entry))
    ITU=$(cut -d, -f6 <(echo $entry))
    
    # Perl syntax for regex match, grep command matches only(-o) amateur radio call sign rule in entry
    is_overriden=$(grep -oP "[=, ]{1}$match([\(\[]?[0-9]+[\)\] ]?){1,2}" <(echo $entry) )
    
    [ "$( grep -o '(' <(echo $is_overriden))" != "" ] && WAZ=$( cut -d '(' -f2 <(echo "$is_overriden") |  cut -d ')' -f1)
    [ "$( grep -o '\[' <(echo $is_overriden))" != "" ] && ITU=$( cut -d '[' -f2 <(echo "$is_overriden") | cut -d ']' -f1)  
    
    echo $ITU $WAZ
}

# Function that checks script arguments, returns "Usage message" if any condition is broken
check_script_requirements(){
    if [[ $# -lt 3 ]] || [[ $# -gt 4 ]] || [[ ! -f $1 ]]; then
        echo -e "Script usage: $0 <correctly formated regular file> <command> <1 or 2 radio call signs depending on command>\n<command> values that can be provided: country, zones, distance(2 arguments)"
        exit 1
    fi
}

# Main function that calls corresponding function according to input command
main(){
    if [[ $command == "country" ]]; then
        get_country
    elif [[ $command == "zones" ]]; then
        get_zones
    elif [[ $command == "distance" ]] && [[ -z $4 ]]; then
        get_distance
    fi
}

check_script_requirements $1 $2 $3 $4

data=$1
command=$2
radio_call_1=$3
[[ $# -eq 4 ]] && radio_call_2=$4

main