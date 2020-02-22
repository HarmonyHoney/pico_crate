import json

def getkey(arg):
    n = int(arg)
    if n < 10:
        return str(n)
    else:
        return chr(n + 87)

print("--- BEGIN ---")

f = open("tinycrate.json")
j = json.load(f)

print("tiled_room = {")

for layer in j["layers"]:
    room = '\t"'

    for i in layer["data"]:
        room += getkey(i)

    room += "," + layer["name"] + '",'

    print(room)
print("}")

print("--- END ---")