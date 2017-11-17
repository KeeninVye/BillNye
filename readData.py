#!/bin/usr/python
import csv, os, sqlite3

conn = sqlite3.connect('db/billnye.db')
c = conn.cursor()
# Create table
#c.execute('''CREATE TABLE stocks (date text, trans text, symbol text, qty real, price real)''')

# Insert a row of data
#c.execute("INSERT INTO stocks VALUES ('2006-01-05','BUY','RHAT',100,35.14)")

# Save (commit) the changes
#conn.commit()

# We can also close the connection if we are done with it.
# Just be sure any changes have been committed or they will be lost.

#c.execute('''CREATE TABLE "transactions" ( `ID` TEXT UNIQUE, `PurchaseDate` TEXT, `Type` TEXT, `Date` TEXT, `Source` TEXT, `Amount` REAL, UNIQUE (`PurchaseDate`, `Type`, `Source`, `Amount`) )''')

data_dir = 'data/'

def insert_row(row):
	try:
		c.execute("INSERT INTO transactions VALUES (?,?,?,?,?,?)", row)
		conn.commit
	except (sqlite3.IntegrityError, sqlite3.ProgrammingError) as err:
		#print err
		#print row
		pass

def read_csvs():
	with open('data/data_file.csv', 'rb') as csvfile:
		spamreader = csv.reader(csvfile, delimiter=',')
		for row in spamreader:
			if len(row) == 7:
				row = row[:-1]
			insert_row(row)

if __name__ =="__main__":
	read_csvs()
	c.execute("SELECT * FROM transactions")
	for row in c.execute('SELECT * FROM transactions ORDER BY ID'):
		print row

conn.close()