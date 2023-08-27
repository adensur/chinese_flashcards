import json

words = set()


for filename in ["cefr_a1_c2.json", "cambridge_a1.json", "cambridge_a2.json", "cambridge_b1.json"]:
    with open(filename, "r") as file:
        for line in file:
            data = json.loads(line)
            words.add(data["word"])

with open("unique.txt", "w") as file:
    for word in words:
        file.write(word.lower() + "\n")