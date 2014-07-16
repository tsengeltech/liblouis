import argparse
import csv
import fileinput
from utils import *

class UTF8Recoder:
    def __init__(self, reader):
        self.reader = reader
    def __iter__(self):
        return self
    def next(self):
        return self.reader.next().encode("utf-8")
        
class Reader:
    def __init__(self, files, encoding):
        self.reader = csv.reader(UTF8Recoder(fileinput.FileInput(files, openhook=fileinput.hook_encoded(encoding))),
                                 delimiter='\t', quoting=csv.QUOTE_NONE)
    def __iter__(self):
        return self
    def next(self):
        type, text, braille, _ = [unicode(s, "utf-8") for s in self.reader.next()]
        if type == "*":
            return {'text': text,
                    'braille': braille}
        else:
            return self.next()

def main():
    parser = argparse.ArgumentParser(description='Submit entries to dictionary.')
    parser.add_argument('FILE', nargs='*', default=['-'], help="TSV file with entries")
    parser.add_argument('-d', '--dictionary', required=True, dest="DICTIONARY",
                        help="dictionary file")
    args = parser.parse_args()
    conn, c = open_dictionary(args.DICTIONARY)
    reader = Reader(args.FILE, "utf-8")
    for row in reader:
        c.execute("UPDATE dictionary SET braille=:braille WHERE text=:text", row)
    conn.commit()
    conn.close()

if __name__ == "__main__": main()