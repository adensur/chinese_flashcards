# converts https://github.com/skishore/makemeahanzi/dictionary.txt to proper format

# output example: {"word":"circle","infinitive":"circle","translations":[{"translation":"круг","frequency":1,"type":"noun"}]}
# input example: {"character":"是","definition":"to be; indeed, right, yes; okay","pinyin":["shì"],"decomposition":"⿱日疋","etymology":{"type":"ideographic","hint":"To speak 日 directly 疋"},"radical":"日","matches":[[0],[0],[0],[0],[1],[1],[1],[1],[1]]}
import argparse
import json
import re

parser = argparse.ArgumentParser(
    description='Converts a file from one format to another.')
parser.add_argument('--input', metavar='input', type=str, help='input file')
parser.add_argument('--output', metavar='output', type=str, help='output file')
# parse args
args = parser.parse_args()

# open files
input_file = open(args.input, 'r')
output_file = open(args.output, 'w')

unique_keys = set()
# read input file
for line in input_file:
    js = json.loads(line)
    # print(js)
    if "definition" not in js:
        continue
    # convert to output format
    output = {}
    output['word'] = js['character']
    output['translations'] = []
    # split by ; or ,
    for translation in re.split(';|,', js['definition']):
        output['translations'].append({'translation': translation.strip()})
    if len(js["pinyin"]) > 0:
        output["pinyin"] = js["pinyin"][0]
    output["decomposition"] = js["decomposition"]
    if "etymology" in js:
        output["etymology"] = js["etymology"]
        for key in js["etymology"].keys():
            unique_keys.add(key)

    # write to output file
    # serialize to json without escaping unicode
    output_js = json.dumps(output, ensure_ascii=False)
    output_file.write(output_js + '\n')

print(unique_keys)
# close files
input_file.close()
output_file.close()
