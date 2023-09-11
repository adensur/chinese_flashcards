import json


# Create a dictionary to store translations from language B to language A
translations_b_to_a = {}

# Iterate through the JSON entries
with open('iw_en/unique_iw.json', 'r', encoding='utf-8') as file:
    for line in file:
        entry = json.loads(line)
        word = entry['word']
        for translation_entry in entry['translations']:
            translation = translation_entry['translation']
            # Check if the translation exists for this word
            if translation not in translations_b_to_a:
                translations_b_to_a[translation] = []
            # Add the translation entry
            translations_b_to_a[translation].append({'word': word})



# Save the inverted JSON data to a new file
with open('iw_en/unique_words.txt', 'w', encoding='utf-8') as output_file:
	for k, v in translations_b_to_a.items():
		print(k, file=output_file)