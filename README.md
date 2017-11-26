# BillNye💰

A library to facilitate in parsing and getting data from Chase Bank statements.

## Installation💽
`go get github.com/keeninvye/BillNye`

## Documentation📜
Coming Soon.

## Usage⌨️
#### Mac Example

```go
// Parse Credit Statement
credit_transactions, err := ParseCreditStatement(`credit_statement.pdf`)
if err != nil {
  panic(err)
}

// Parse Debit Statement
debit_transactions, err := ParseDebitStatement(`debit_statement.pdf`)
if err != nil {
  panic(err)
}
```

## Contributing🍄

Please sen pull requests! It would be great to have more support for other bank statements, i.e. BoA, BECU, Wells Fargo.  Giving more people the ability to access their raw transaction data will be very beneficial!
