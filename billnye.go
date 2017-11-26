package billNye

import (
    "fmt"
    "log"
    "strings"
    "os"
    "os/exec"
    "reflect"
    "regexp"
)

//Debug enbles more verbose debug output to console
var Debug bool

type DebitTransaction struct {
    Date    string
    Type    string
    Source  string
    Amount  string
}

type CreditTransaction struct {
    Date    string
    Type    string
    Source  string
    Amount  string
}

func NewDebitTransaction(Date string, Source string, Amount string) (*DebitTransaction){
    dt          := DebitTransaction{}
    dt.Date     = Date
    dt.Type     = "Debit"
    dt.Source   = Source
    dt.Amount   = Amount
    return &dt
}

func NewCreditTransaction(Date string, Source string, Amount string) (*CreditTransaction){
    ct          := CreditTransaction{}
    ct.Date     = Date
    ct.Type     = "Credit"
    ct.Source   = Source
    ct.Amount   = Amount
    return &ct
}

//Parse multiple credit statements
func ParseCreditStatements(path_to_dir string) (){

}

//Parse a single credit statement
func ParseCreditStatement(path string) (credit_transactions []*CreditTransaction, err error){
    f, err := os.Open(path)

    REX_CREDIT_MATCH        := "[\t ]*([0-9]{2}/[0-9]{2}) +(.+ ) *([-,0-9]+\\.[0-9]{2})"
    REX_CREDIT, _           := regexp.Compile("[\t ]*([0-9]{2}/[0-9]{2}) +(.+ ) *([-,0-9]+\\.[0-9]{2})")

    if err != nil {
        log.Fatal(err)
    }

    credit_text        := ParsePDF(f)
    parsed_credit_text := strings.Split(credit_text,"\n")
    var count int
    for elem, char := range parsed_credit_text {
        fmt.Println(elem)
        match, _ := regexp.MatchString(REX_CREDIT_MATCH, char)
        if(match == true) {
            var Date string
            var Source string
            var Amount string
            transaction := REX_CREDIT.FindStringSubmatch(char)
            for group, text := range transaction {
                switch group{
                    case 1:
                        Date = strings.TrimSpace(text)
                    case 2:
                        Source = strings.TrimSpace(text)
                    case 3:
                        Amount = strings.TrimSpace(text)
                }
            }
            ct := NewCreditTransaction(Date, Source, Amount)
            credit_transactions = append(credit_transactions, ct)
            fmt.Println(ct)
            count = count + 1

        }
    }
    debug("Count: ", count)

    return credit_transactions, err
}

//Parse a single credit statement
func ParseDebitStatement(path string) (debit_transactions []*DebitTransaction, err error){
    f, err := os.Open(path)

    //list := []*DebitTransaction{}

    REX_DEBIT_MATCH := "[ \t]*([0-9]{2}/[0-9]{2})[ \t]*([\\w \\/\\.\\#\\:\\-\\*]+ )([0-9\\-\\,]+\\.[0-9]{2}) +"
    REX_DEBIT, _    := regexp.Compile("[ \t]*([0-9]{2}/[0-9]{2})[ \t]*([\\w \\/\\.\\#\\:\\-\\*]+ )([0-9\\-\\,]+\\.[0-9]{2}) +")

    if err != nil {
        log.Fatal(err)
    }

    debit_text        := ParsePDF(f)
    parsed_debit_text := strings.Split(debit_text,"\n")
    var count int
    for elem, char := range parsed_debit_text {
        fmt.Println(elem)
        fmt.Println(char)
        match, _ := regexp.MatchString(REX_DEBIT_MATCH, char)
        if(match == true) {
            var Date string
            var Source string
            var Amount string
            transaction := REX_DEBIT.FindStringSubmatch(char)
            for group, text := range transaction {
                switch group{
                    case 1:
                        Date = strings.TrimSpace(text)
                    case 2:
                        Source = strings.TrimSpace(text)
                    case 3:
                        Amount = strings.TrimSpace(text)
                }
            }
            dt := NewDebitTransaction(Date, Source, Amount)
            debug(dt)
            debit_transactions = append(debit_transactions, dt)
            count = count + 1
        }
    }
    debug("Count: ", count)

    return debit_transactions, err
}

func ParsePDF(f *os.File) (string){
    // Document body
    bc := make(chan string, 1)
    fmt.Println(reflect.TypeOf(bc))
    go func() {// "-q", "-nopgbrk", "-enc", "UTF-8", "-eol", "unix",
        body, err := exec.Command("pdftotext", "-layout", f.Name(), "-").Output()

        if err != nil {
            // TODO: Remove this.
            debug("pdftotext:", err)
        }

        bc <- string(body)
    }()

    return <-bc
}

func debug(s ...interface{}) {
    if Debug {
        fmt.Println(s...)
    }
}
