import csv
import glob
import numpy as np
import datetime
import math
import matplotlib.pyplot as pyplot

flist = glob.glob("data/report-*.csv")

# Date,Time,System Setting,System Mode,Calendar Event,Program Mode,Cool Set Temp (F),
# Heat Set Temp (F),Current Temp (F),Current Humidity (%RH),Outdoor Temp (F),
# Wind Speed (km/h),Cool Stage 1 (sec),Cool Stage 2 (sec),Heat Stage 1 (sec),Heat Stage 2 (sec),
# Fan (sec),DM Offset,Thermostat Temperature (F),Thermostat Humidity (%RH),Thermostat Motion,
# Downstairs (F),Downstairs2,Kids' Room (F),Kids' Room2,Bedroom (F),Bedroom2

#flist = [flist[0]]
jval = 0
ndays = 0
saved_fields = ["Current Temp (F)", "Outdoor Temp (F)",
                "Cool Stage 2 (sec)"]

fine_time_dtype = [('indoor_temp', 'f8'),
                   ('outdoor_temp', 'f8'),
                   ('cooling_sec', 'f8'),
                   ('heating_sec', 'f8'),
                   ('day_dec', 'f8'),
                   ('day_int', 'f8'),
                   ('year', 'f8')]


def float_or_NaN(sstr):
    if len(sstr) == 0: return np.NaN
    try:
        num = float(sstr)
    except:
        num = np.NaN
    return num


row_list = []
ii_first = True
for fname in flist:
    fp = open(fname)
    CSV = csv.DictReader(row for row in fp if not (row.startswith('#') or len(row) < 4))

    for row in CSV:
        t = np.zeros(1, dtype=fine_time_dtype)  # .view(np.recarray)

        t['indoor_temp'] = float_or_NaN(row["Current Temp (F)"])
        t['outdoor_temp'] = float_or_NaN(row["Outdoor Temp (F)"])
        cs1 = float_or_NaN(row["Cool Stage 1 (sec)"])
        cs2 = float_or_NaN(row["Cool Stage 2 (sec)"])
        t['cooling_sec'] = max([cs1, cs2])

        hs1 = float_or_NaN(row["Heat Stage 1 (sec)"])
        hs2 = float_or_NaN(row["Heat Stage 2 (sec)"])
        t['heating_sec'] = max([hs1, hs2])

        date_vals = row["Date"].split("-")
        year0 = datetime.datetime(int(date_vals[0]), 1, 1)
        row_date = datetime.datetime.strptime(row["Date"] + " " + row["Time"], "%Y-%m-%d %H:%M:%S")
        td = row_date - year0
        jday = td.days + td.seconds / 3600. / 24.
        t['day_dec'] = jday
        t['day_int'] = math.floor(jday)
        t['year'] = year0.year

        if len(row_list) > 0 and t['day_int'] != row_list[-1]['day_int']:
            ndays = ndays + 1
        row_list.append(t)

        #if len(row_list) > 20: break


mat_dhr_data = np.concatenate(row_list)
mat_dhr = mat_dhr_data.view(np.recarray)
print(mat_dhr_data)
print(mat_dhr)

# mat_dhr's data, viewed as a [ndays,nchar] matrix
mat_dhr_data = mat_dhr_data.view('f8').reshape( (-1,len(fine_time_dtype)) )

pyplot.plot(mat_dhr.day_dec, mat_dhr.outdoor_temp)
pyplot.plot(mat_dhr.day_dec, mat_dhr.indoor_temp)

mat_dday_data = np.zeros(ndays + 1, dtype=fine_time_dtype)
mat_dday = mat_dday_data.view(np.recarray)
mat_dday_data = mat_dday_data.view('f8').reshape( (-1,len(fine_time_dtype)) )

day_accum = np.zeros(1, dtype=fine_time_dtype)
day_accum_data = day_accum.view('f8')

jDay = 0
nday_accum = 0
dT_Hr = 0
j1 = 0

print(mat_dhr_data.shape)
for jHr in range(mat_dhr.shape[0]):

    if jHr > 0 and mat_dhr[jHr].day_int != mat_dhr[jHr - 1].day_int:
#        print('jDay={0:3d} Hr={1:3.4f} ({2:3d}) vals={3:3d}'.format(
#            jDay, mat_dhr[jHr].day_dec, jHr, nday_accum))

        mat_dday_data[jDay,:] = np.divide(day_accum_data, nday_accum)
        mat_dday[jDay].cooling_sec = day_accum['cooling_sec']
        mat_dday[jDay].heating_sec = day_accum['heating_sec']

        jDay += 1
        nday_accum = 0
        day_accum_data[:] = 0
    if jHr > 0:
        dT_Hr = 24 * (mat_dhr[jHr].day_dec - mat_dhr[jHr-1].day_dec)
    iiok = np.isfinite(mat_dhr_data[jHr,:]).all()
    if not iiok: continue
    day_accum_data += mat_dhr_data[jHr,:].view('f8')

    nday_accum += 1

pyplot.figure()

ii_cool = mat_dday.cooling_sec > 3600*0.25
ii_heat = mat_dday.heating_sec > 3600*0.25
pyplot.scatter(mat_dday.outdoor_temp[ii_cool],mat_dday.cooling_sec[ii_cool]/3600,c='b')
pyplot.scatter(mat_dday.outdoor_temp[ii_heat],mat_dday.heating_sec[ii_heat]/3600,c='r')
#pyplot.plot(mat_dday.cooling_sec/3600)
