import firebase_admin, time
from firebase_admin import credentials
from firebase_admin import firestore

# Use a service account
cred = credentials.Certificate('jungletournament-c6e71-firebase-adminsdk-9t4t9-efc43f9b81.json')
firebase_admin.initialize_app(cred)

db = firestore.client()

users_ref = db.collection(u'matchs')
docs = users_ref.stream()

new_doc = {}

for doc in docs:
    new_doc[int(doc.id)] = doc

new_doc = sorted(new_doc.items())
last_terminated = None
winner = None

for key, doc in new_doc:
    document = doc.to_dict()
    # Si moins de deux opposants, on ajoute le gagnant de ce tour
    if len(document['opponents']) < 2 and winner != None:
        document['opponents'].append(winner)
        db.collection(u'matchs').document(doc.id).set(document)
        winner = None
    # Termine le match déjà commencé
    if document['started'] and not document['finished']:
        document['finished'] = True
        db.collection(u'matchs').document(doc.id).set(document)
        winner = document['opponents'][document['votes'][0] <= document['votes'][1]]
        last_terminated = key
    # Commence le match suivant
    if last_terminated != None and last_terminated != key:
        time.sleep(1)
        last_terminated = None
        document['started'] = True
        db.collection(u'matchs').document(doc.id).set(document)

# Si aucun match n'est commencé, commence le premier
key, value = new_doc[0]
if not value.to_dict()['started']:
    document = value.to_dict()
    document['started'] = True
    db.collection(u'matchs').document(value.id).set(document)
