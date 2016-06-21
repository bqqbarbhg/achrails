#!/usr/bin/python

import csv
import datetime 
import sys
import collections
try:
    import anonymizer
    user_mapping = anonymizer.user_names
    #group_mapping = anonymizer.group_names
except ImportError:
    user_mapping = None
    #group_mapping = None

# e.g. 
# python3 readachsolog.py  > achso_weekly.txt
# or ./readachsolog.py dump.txt > achso_weekly.txt

# Use this to dump weekly stats achrails log dump. This doesn't handle changing years, fix keys in 'weeks' to also include year when this is needed. Also you may want to add a way to set starting date.   
if len(sys.argv) > 1:
    file = open(sys.argv[1])
else:
    file = open('achsodump.csv')
lines = csv.reader(file, delimiter=',')
weeks = {}


for itemtuple in lines:
    if len(itemtuple) != 6:
        continue
    datestamp, action, a, b, c, d = itemtuple
    # 2016-04-18 13:21:02 UTC
    try:
        dd = datetime.datetime.strptime(datestamp, "%Y-%m-%d %H:%M:%S %Z")
    except ValueError:
        continue
    data = {'date': dd, 'action': action}
    if action in ['view_video', 'upload_video', 'edit_video', 'delete_video']:
        data['userid'] = a
        data['video_id'] = b        
    elif action == 'publish_video':
        data['userid'] = a
        data['video_id'] = b        
        data['is_public'] = d
    elif action in ['create_group', 'join_group', 'leave_group', 'delete_group']:
        data['userid'] = a
        data['group_id'] = b        
    elif action == 'share_video':
        data['userid'] = a
        data['video_id'] = b 
        data['group_id'] = c       
        data['is_public'] = d
    else:
        print('missing action:', action)
    year, week_n, weekday = dd.isocalendar()
    week_n = int(week_n / 2) 
    if week_n in weeks:
        w_actions = weeks[week_n]
    else:
        w_actions = {}
        weeks[week_n] = w_actions
    if action in w_actions:
        w_actions[action].append(data)
    else:
        w_actions[action] = [data]
video_authors = {}
def zero():
    return 0

for week_n in sorted(list(weeks.keys())):
    w_actions = weeks[week_n]
    week_start = datetime.datetime.strptime('2016 %s 1' % (int(week_n * 2)), '%Y %W %w')
    print('------- Week %s (%s)--------' % (week_n * 2, week_start))
    user_pool = set()
    video_edits = 0
    user_events = collections.defaultdict(list)
    video_views = collections.defaultdict(zero)
    if 'upload_video' in w_actions:
        for event in w_actions['upload_video']:
            video_authors[event['video_id']] = event['userid'] 
    if 'edit_video' in w_actions:          
        for event in w_actions['edit_video']:
            if event['video_id'] in video_authors:
                if video_authors[event['video_id']] != event['userid']:
                    video_edits += 1 
    for action_key in sorted(list(w_actions.keys())):
        events = w_actions[action_key]
        #print('%s: %s' % (action_key, len(events)))
        for event in events:
            user_pool.add(event['userid'])
            user_events[event['userid']].append(event)
    for view_item in w_actions['view_video']:
        video_views[view_item['video_id']] += 1
    #print('user_ids_active: %s' % len(user_pool))
    #print('edits to other peoples videos: %s' % video_edits)


    # - Total number of unique users in period
    print('Total number of unique users in period: %s' % len(user_pool))

    # - Total number of videos viewed in period
    print('Total number of videos viewed in period: %s' % len(w_actions.get('view_video', [])))
    # - Total number of videos added in period
    print('Total number of videos added in period: %s' % len(w_actions.get('upload_video', [])))
    # - Total number of videos deleted in period
    print('Total number of videos deleted in period: %s' % len(w_actions.get('delete_video', [])))
    # - Total number of groups created in period
    print('Total number of groups created in period: %s' % len(w_actions.get('create_group', [])))
    # - Total number of groups deleted in period
    print('Total number of groups deleted in period: %s' % len(w_actions.get('delete_group', [])))
    # - Total number of users that joined a group in period
    print('Total number of users that joined a group in period: %s' % len(w_actions.get('join_group', [])))
    # - Total number of users that left a group in period
    print('Total number of users that left a group in period: %s' % len(w_actions.get('leave_group', [])))
    # - Distribution of events per user in period
    print('Events for users:')
    for userid in sorted(user_events.keys()):
        events = user_events[userid]
        pile = collections.defaultdict(zero)
        for item in events:
            pile[item['action']] += 1
        if user_mapping:            
            print('%s: %s' % (user_mapping[int(userid)], dict(pile)))
    # - Distribution of views per video in period
    print('Total number of views for videos:')
    print(list(video_views.items()))
    #for videoid, views in video_views.items():
    #    print('%s: %s' % (videoid, views))


