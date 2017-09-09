import sqlite3
import csv
import time

#extract kb data
connection = sqlite3.connect('kb.db')
cursor = connection.cursor()
cursor.execute('SELECT id, title, description, owner_id, creator_id, is_active from Tasks where project_id=1')


#Set up sqlite3 connection
conn = sqlite3.connect('gogs.db')
c = conn.cursor()

#Default values for columns not in the kb db
repo_id = 20 
index = 4
milestone_id = 0
priority = 0
is_pull = 0
num_comments = 0
deadline_unix = 0
created_unix = round(time.time())
updated_unix = created_unix

poster_id = 6
assignee_id = 0

taskIdDict = {}
kbUserNames = ["","admin","","","jkern","nneitman","brandon","jcsky","jackh","ssimon","kgluck","joshz","mfreiman","anitaa"]
gogsUserNames = {
    "": 4,
    "admin": 4,
    "jkern": 4,
    "nneitman": 4,
    "brandon": 9,
    "jcsky": 6,
    "jackh": 5,
    "ssimon": 13,
    "kgluck": 10,
    "joshz": 2,
    "mfreiman": 14,
    "anitaa": 4,
}
closedArray = [1,0]

# Read and transfer tasks to issues
for row in cursor:
    content = row[2] + '\n\n-' + kbUserNames[int(row[4])]
    g_user = gogsUserNames[kbUserNames[int(row[4])]]
    c.execute("INSERT INTO issue('repo_id', 'index', 'poster_id','name','content','milestone_id','priority','assignee_id','is_closed','is_pull','num_comments','deadline_unix','created_unix','updated_unix') VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)",[repo_id,index,g_user,row[1],content,milestone_id,priority,assignee_id,closedArray[int(row[5])],is_pull,num_comments,deadline_unix,created_unix,updated_unix])
    c.execute('select id from issue where "index"=?',[index])
    taskIdDict[row[0]] = c.fetchone()[0]
    index+=1
c.execute('UPDATE repository set "num_issues"=? where "id"=?', [index, repo_id])
conn.commit()

cursor.execute('SELECT task_id, user_id, comment from Comments')
for row in cursor:
    if (row[0] in taskIdDict):
        content = row[2] + '\n\n-' + kbUserNames[int(row[1])]
        g_user = gogsUserNames[kbUserNames[int(row[1])]]
        c.execute("INSERT INTO comment('type', 'poster_id', 'issue_id', 'commit_id', 'line', 'content', 'created_unix', 'updated_unix') VALUES(0, ?, ?, 0,0,?,?, ?)", [g_user,taskIdDict[row[0]],content,created_unix, updated_unix]);
conn.commit()
