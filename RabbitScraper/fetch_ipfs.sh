#!/bin/bash



curl https://cnft.tools/api/external/85c6a29c993863d020ccce88c8a5dfc114392da6f5949a3cd462216c/ | jq 'map(.iconurl)' > supremes_ifps_locs.txt
