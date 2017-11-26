package billNye

import (
    "testing"
)

func TestStatementParse(t *testing.T) {
    Debug = true

    debit_content, debit_err := ParseDebitStatement(`debit.pdf`)
    t.Log(debit_content)
    if debit_err != nil {
        t.Fatal(debit_err)
    }


    credit_content, credit_err := ParseCreditStatement(`test.pdf`)
    t.Log(credit_content)
    if credit_err != nil {
        t.Fatal(credit_err)
    }
}
