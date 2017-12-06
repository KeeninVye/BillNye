package billNye

import (
    "testing"
)

func TestStatementParse(t *testing.T) {
    Debug = true

    bn := BillNye{}
    bn.ParseDebitStatement(`debit.pdf`)
    /*debit_content, debit_err := bn.ParseDebitStatement(`debit.pdf`)
    t.Log(debit_content)
    if debit_err != nil {
        t.Fatal(debit_err)
    }
    */

    bn.ParseCreditStatement(`test.pdf`)
    t.Log(bn.credit_transactions)

    /*credit_content, credit_err := bn.ParseCreditStatement(`test.pdf`)
    t.Log(credit_content)
    if credit_err != nil {
        t.Fatal(credit_err)
    }*/
}
