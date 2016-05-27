import csv
import datetime 

# e.g. 
# python3 readachsolog.py > achso_weekly.txt

# Use this to dump weekly stats achrails log dump. This doesn't handle changing years, fix keys in 'weeks' to also include year when this is needed. Also you may want to add a way to set starting date.   

file = open('achsodump.csv')
lines = csv.reader(file, delimiter=',')
weeks = {}

for datestamp, action, a, b, c, d in lines:
    # 2016-04-18 13:21:02 UTC
    dd = datetime.datetime.strptime(datestamp, "%Y-%m-%d %H:%M:%S %Z")
    data = {'date': dd}
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
for week_n in sorted(list(weeks.keys())):
    w_actions = weeks[week_n]
    week_start = datetime.datetime.strptime('2016 %s 1' % week_n, '%Y %W %w')
    print('------- Week %s (%s)--------' % (week_n, week_start))
    user_pool = set()
    video_edits = 0
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
        print('%s: %s' % (action_key, len(events)))
        for event in events:
            user_pool.add(event['userid'])
    print('user_ids_active: ', len(user_pool))
    print('edits to other peoples videos: ', video_edits)