__author__ = 'Yi'
import csv
import time

def CreateTimeIndex(start_time, end_time, dt):
    times = []
    time_idx = 1
    times.append(start_time)

    start_time_str = start_time[0]+' '+start_time[1]
    start_time_struct = time.strptime(start_time_str,"%d-%b-%Y %H:%M:%S")
    start_time_sec = time.mktime(start_time_struct)
    end_time_str = end_time[0]+' '+end_time[1]
    end_time_struct = time.strptime(end_time_str,"%d-%b-%Y %H:%M:%S")
    end_time_sec = time.mktime(end_time_struct)

    dt_in_sec = dt*60
    time_sec = start_time_sec + dt_in_sec
    while time_sec <= end_time_sec:
        time_idx += 1
        time_str = time.strftime("%d-%b-%Y %H:%M:%S",time.localtime(time_sec))
        time_list = time_str.split(' ')
        times.append(time_list)
        time_sec += dt_in_sec
    return times

def MatchTimeStepData(input_file,input_type,input_folder,times,is_time_sliced):

    if is_time_sliced:
#        acceptable_error = abs(time.mktime(time.strptime(times[0],"%d-%b-%Y %H:%M:%S")) - time.mktime(time.strptime(times[1],"%d-%b-%Y %H:%M:%S"))) - 30
        acceptable_error = 3600 - 30

    ts_input = open(input_file)
    ts_reader = csv.reader(ts_input)
    ts_fields = ts_reader.next()
    day_idx = ts_fields.index('DAY')
    time_idx = ts_fields.index('TIME_OF_DAY')
    ts_temp = {}
    if input_type == 'flow':
        link_idx = ts_fields.index('LINK_ID')
        for ts_rec in ts_reader:
            link_id = ts_rec[link_idx]
            if link_id not in ts_temp.keys():
                ts_temp[link_id] = []
                ts_temp[link_id].append(ts_rec)
            else:
                ts_temp[link_id].append(ts_rec)
    elif input_type == 'turn ratio':
        inlink_idx = ts_fields.index('IN_LINK_ID')
        outlink_idx = ts_fields.index('OUT_LINK_ID')
        for ts_rec in ts_reader:
            link_pair = [ts_rec[inlink_idx],ts_rec[outlink_idx]]
            if tuple(link_pair) not in ts_temp.keys():
                ts_temp[tuple(link_pair)] = []
                ts_temp[tuple(link_pair)].append(ts_rec)
            else:
                ts_temp[tuple(link_pair)].append(ts_rec)
    ts_input.close()
    ts_outs = []
    ts_outs.append(ts_fields)

    for link in ts_temp.keys():
        ts_by_link = ts_temp[link]
        initial_term = ts_by_link[0]
        initial_approx = initial_term[day_idx]+' '+initial_term[time_idx]
        initial_sec = time.mktime(time.strptime(initial_approx,"%d-%b-%Y %H:%M:%S"))
        for time_slice in times:
            if is_time_sliced:
                time_slice_str = time_slice
                time_slice = time_slice_str.split(' ')
            else:
                time_slice_str = time_slice[0]+' '+time_slice[1]
            time_slice_sec = time.mktime(time.strptime(time_slice_str,"%d-%b-%Y %H:%M:%S"))
            initial_error = abs(time_slice_sec-initial_sec)
            closest = [0,initial_error]

            closest_idx = 0
            for candidate in ts_by_link:
                if closest_idx != 0:
                    candidate_str = candidate[day_idx]+' '+candidate[time_idx]
                    candidate_sec = time.mktime(time.strptime(candidate_str,"%d-%b-%Y %H:%M:%S"))
                    candidate_error = abs(candidate_sec-time_slice_sec)
                    if candidate_error < closest[1]:
                        closest = [closest_idx,candidate_error]
                closest_idx += 1
            time_slice_data_ref = ts_by_link[closest[0]]
            time_slice_data = time_slice_data_ref[:]
            time_slice_data[day_idx] = time_slice[0]
            time_slice_data[time_idx] = time_slice[1]

            if is_time_sliced:
                if closest[1] <= acceptable_error:
                    ts_outs.append(time_slice_data)
            else:
                ts_outs.append(time_slice_data)

    if input_type == 'flow':
        ts_output = open(input_folder+'/Approach Flows TS.csv','w')
    elif input_type == 'turn ratio':
        ts_output = open(input_folder+'/Turn Ratios TS.csv','w')
    ts_writer = csv.writer(ts_output, lineterminator='\n')
    ts_writer.writerows(ts_outs)
    ts_output.close()
