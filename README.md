# Bill::Nye

A library to facilitate in parsing and getting data from Chase Bank statements.

## Installation

Add this line to your application's Gemfile:

    gem 'bill-nye'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install BillNye

## Usage

	To parse a single Chase Bank debit card statement:
	$ b = BillNye.new
  	$ b.parse_pdf('path/to/bank/statement.pdf', 1)

	To parse multiple Chase Bank debit card statements:
  	$ b.parse_pdfs('path/to/bank/statements/', 1)

  	The second argument of the parse_pds(s) function determines what type of statement you are going to parse.

	To parse a single Chase Bank credit card statement:
	$ b = BillNye.new
  	$ b.parse_pdf('path/to/bank/statement.pdf', 2)

	To parse multiple Chase Bank credit card statements:
  	$ b.parse_pdfs('path/to/bank/statements/', 2)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
