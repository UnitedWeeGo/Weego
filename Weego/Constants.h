#define HEXCOLOR(c) [UIColor colorWithRed:((c>>24)&0xFF)/255.0 \
green:((c>>16)&0xFF)/255.0 \
blue:((c>>8)&0xFF)/255.0 \
alpha:((c)&0xFF)/255.0];

#define TIMER_EVENT_MINUTE @"timerEventMinute"

#define CHECKIN_TIME_RANGE_MINUTES 90
#define CHECKIN_RADIUS_THRESHOLD 60
#define CHECKIN_ACCURACY_THRESHOLD 100
#define STALE_DATA_FETCH_MINUTES_THRESHOLD 30
#define REPORTING_LOCATION_DISTANCE_TRAVELLED_METERS_THRESHOLD 50
#define DATA_FETCH_TIMEOUT_SECONDS_INTERVAL 8
#define GOOGLE_API_KEY @"AIzaSyAIcJ2O5wb1INKqMQzPDnak6f-Z2pbq1mw"
#define GOOGLE_ANALYTICS_PROPERTY_ID @"UA-24038628-2"
#define GOOGLE_ANALYTICS_DISPATCH_PERIOD 10
#define SIMLE_GEO_SEARCH_RESULTS_COUNT 35

// User setting keys
#define USER_PREF_ALLOW_TRACKING @"allowsTracking"