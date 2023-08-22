import json

words = set()

with open("cefr_a1_c2.json", "r") as file:
    for line in file:
        data = json.loads(line)
        if data["word"] not in words:
            print(line.rstrip("\n"), )
            words.add(data["word"])
