package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"io"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
)

var (
	input    = flag.String("input", "", "Input file")
	langFrom = flag.String("lang-from", "hi", "Language in google translate's 2 letter abbreviation")
	langTo   = flag.String("lang-to", "en", "Language in google translate's 2 letter abbreviation")
)

type Detail struct {
	Translation string  `json:"translation"`
	Frequency   float64 `json:"frequency"`
	Type        string  `json:"type"`
}

func parseWordType(wordType int, word string) string {
	switch wordType {
	case 1:
		return "noun"
	case 2:
		return "verb"
	case 3:
		return "adjective"
	case 4:
		return "adverb"
	case 5:
		return "preposition"
	case 6:
		return "abbreviation"
	case 7:
		return "conjunction"
	case 8:
		return "pronoun"
	case 9:
		return "interjection"
	case 10:
		return "phrase"
	case 11:
		return "prefix"
	case 12:
		return "suffix"
	case 13:
		return "article"
	case 15:
		return "numeral"
	case 16:
		return "auxiliary verb"
	case 17:
		return "exclamation"
	case 19:
		return "particle"
	case 20:
		return "unknown"
	default:
		panic(fmt.Errorf("unknown word type %v for word %v", wordType, word))
	}
}

func getDetails(word, langFrom, langTo string) (*Output, error) {
	encodedWord := url.QueryEscape(word)
	url := "https://translate.google.com/_/TranslateWebserverUi/data/batchexecute?rpcids=rPsWke&source-path=%2F&f.sid=5317742920953228612&bl=boq_translate-webserver_20250204.08_p0&hl=en&soc-app=1&soc-platform=1&soc-device=1&_reqid=737481&rt=c"
	payload := "f.req=%5B%5B%5B%22rPsWke%22%2C%22%5B%5B%5C%22" + encodedWord + "%5C%22%2C%5C%22" + langFrom +
		"%5C%22%2C%5C%22" + langTo + "%5C%22%5D%2C1%5D%22%2Cnull%2C%22generic%22%5D%5D%5D&at=AKt-4RDM5y2oHLQTEVPIf_3OScO2%3A1738837480713&"

	fmt.Println("Payload:", payload)
	req, err := http.NewRequest("POST", url, bytes.NewBuffer([]byte(payload)))
	if err != nil {
		panic(err)
	}

	req.Header.Add("accept", "*/*")
	req.Header.Add("accept-language", "en-US,en;q=0.9")
	req.Header.Add("content-type", "application/x-www-form-urlencoded;charset=UTF-8")
	req.Header.Add("origin", "https://translate.google.com")
	req.Header.Add("priority", "u=1, i")
	req.Header.Add("referer", "https://translate.google.com/")
	req.Header.Add("sec-ch-ua", `"Chrome";v="131", "Chromium";v="131", "Not_A Brand";v="24"`)
	req.Header.Add("sec-ch-ua-arch", `"arm"`)
	req.Header.Add("sec-ch-ua-bitness", `"64"`)
	req.Header.Add("sec-ch-ua-form-factors", `"Desktop"`)
	req.Header.Add("sec-ch-ua-full-version", `"131.0.6778.1038"`)
	req.Header.Add("sec-ch-ua-full-version-list", `"Chrome";v="131.0.6778.1038", "Chromium";v="131.0.6778.1038", "Not_A Brand";v="24.0.0.0"`)
	req.Header.Add("sec-ch-ua-mobile", "?0")
	req.Header.Add("sec-ch-ua-model", `""`)
	req.Header.Add("sec-ch-ua-platform", `"macOS"`)
	req.Header.Add("sec-ch-ua-platform-version", `"15.3.0"`)
	req.Header.Add("sec-ch-ua-wow64", "?0")
	req.Header.Add("sec-fetch-dest", "empty")
	req.Header.Add("sec-fetch-mode", "cors")
	req.Header.Add("sec-fetch-site", "same-origin")
	req.Header.Add("user-agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36")
	req.Header.Add("x-client-data", "CJySywE=")
	req.Header.Add("x-goog-batchexecute-bgr", `[";kI64jtbQAAYSKdMVMilf80pKWMTjqRcmADQBEArZ1LjhAtJnB7JSRGRJrbWfEHGVYJsrk_W6Y2WC61ueTq6GehqjNJ1SkSHs1L6m_UDcHwAAACFPAAAAAXUBB2MAQfLc3EBO7USDUj3khjN4H01VjfxrC5o9mhgfNguui1y0_aRdRbx3hQPTL4As6l2aIoDReYeBl2byAFg8BwgdrMBPhAM0-JoWL0GGkcU5HvSS9hOqsJ_klX6__9eXB5KVDSWxHMmLV1awk-28YU6ncC-V0FwNM3xuVTRIPa1y0yyjXDEskpdH-2awYuJrb2hyrCyXTAMCfIbIzKJYa1Xw7owRmYEM1g0GP--nW3_hGOK0sq4tKFuoYXXc3Sxfrzq_4VhsYDniY4RRTk2yXQZI78Y44IP9NB25U0WH5PNEj7Zv9kfBM1-FMShW0fE2woE5FrmKdtdYEEC6B9z0Zu5gTgrlaNAwmSR_2NGvicIRWy-J_mpX6l6yapqlyZmfzNBUrf50Q3qb7I0d_wJMexuKNq8AenEJ96stYHred071V5fy4Jp3A75MaIgte-Fv7Xc9JCTpXdNr_g21zojrxoK30BXWbe0PwcZfttmf_RHjb-MDOpDVWcH9PDfKPhoV8ZXRduOwJ5fgUcovVa9DsNER0j5aX39lr72mgxo-DdCZkXjQabzoNo2v7QeI87wt78CC--4e6MF1xBaX-9ZDTwwl02XYsi0A7DuOHF9YiSRnrc2PTHqD8zK_k6_oMMjGXqr6u1Ftxf57mglnEZyFa7RV600nD1hq_aYOoWsPI9SbmZPNrrhvQS7_niGNJDMTOyShnyBWquUD0QVgv2OYE5X9YiwxUZYcE-9W3FJaqMYII2de0NMtrOBVQtctXm52Ai5pYYGS5iKY-fjJviYkllTmPMVNuaB-j-ty_EnpFXeVXzr15io8smaYPtMFVoyaXijThMO_1WGIKtlfy1j7IBzhF-zsoRPdH3q8PouXhPJ7J-iRcNr4TbG5ZjqZ9VEo9uC_hNxvhz7ALXQ-v2tHoQV4p9tAowhujSJftm0FtStHu8fz5rFmhMRSMNiDlchShJi5OuXwVucILhWBPyJBCsA5widdgpFaVHlryTtYuhASRgMFFMMt4SOA_KsdelaaTNMUlFG1Nc-9ool-a8g2aTcMdi1ptcMRWpS6916tOhpLqrfbrBZdgWekouLJH-UL_wroapkZM5jBvjPGkT_Cu3sXVA7zww-jZDEFYXD9XzokNnMS1U8tBD99NJEBtEx3XqXi5aCqU0QtFaKiCZHdoDnFqXsPVItcHr3vzQ",null,null,11,null,null,null,0,"2"]`)
	req.Header.Add("x-same-domain", "1")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		panic(err)
	}
	defer resp.Body.Close()

	fmt.Fprintln(os.Stderr, "Response Status:", resp.Status)
	if resp.Status != "200 OK" {
		return nil, fmt.Errorf("transient")
	}
	// Read and print the response body
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		panic(err)
	}
	fmt.Println("Response Body:", string(body))
	result := Output{
		Word:         word,
		Translations: make([]Detail, 0),
	}
	lines := strings.Split(string(body), "\n")
	for _, line := range lines {
		if strings.Contains(line, "rPsWke") {
			// println(line)
			var data [][]interface{}
			err := json.Unmarshal([]byte(line), &data)
			if err != nil {
				panic(fmt.Errorf("Unmarshal #1 of data %v, err %v", line, err))
			}
			subdata, ok := data[0][2].(string)
			if !ok {
				panic("not ok #0")
			}
			fmt.Fprintf(os.Stderr, "\nSubdata: %v\n", subdata)
			var subdata2 []interface{}
			err = json.Unmarshal([]byte(subdata), &subdata2)
			if err != nil {
				panic(fmt.Errorf("Unmarshal #2 of data %v, err %v", subdata, err))
			}
			// fmt.Printf("\nSubdata2: %v\n", subdata2)
			subdata3, ok := subdata2[0].([]interface{})
			if !ok {
				return &result, fmt.Errorf("not ok1")
			}
			// fmt.Printf("\nSubdata3: %v\n", subdata3)
			// example translations + frequencies
			if len(subdata3) < 5 {
				// transient error, needs retry!
				fmt.Fprintf(os.Stderr, "Subdata3 too short: %v\n", subdata3)
				return nil, fmt.Errorf("transient")
			}
			// infinitive
			infinitive, ok := subdata3[0].(string)
			if !ok {
				panic("Failed to find infinitive")
			}
			result.Infinitive = infinitive
			// translation details
			subdata4, ok := subdata3[5].([]interface{})
			if !ok {
				// not transient error
				return &result, nil
			}
			// fmt.Printf("\nSubdata4: %v\n", subdata4)
			subdata5, ok := subdata4[0].([]interface{})
			if !ok {
				panic("not ok3")
			}
			// fmt.Printf("\nSubdata5: %v\n", subdata5)
			for i := range subdata5 {
				subdata6, ok := subdata5[i].([]interface{})
				if !ok {
					panic("not ok4")
				}
				// word type
				wordType, ok := subdata6[4].(float64)
				parsedWordType := parseWordType(int(wordType), word)
				// fmt.Printf("\nSubdata6: %v\n", subdata6)
				subdata7, ok := subdata6[1].([]interface{})
				for j := range subdata7 {
					subdata8, ok := subdata7[j].([]interface{})
					if !ok {
						panic("not ok5")
					}
					// fmt.Printf("\nSubdata8: %v\n", subdata8)
					translation, ok := subdata8[0].(string)
					if !ok {
						panic("not ok6")
					}
					freq, ok := subdata8[3].(float64)
					if !ok {
						panic("not ok7")
					}
					result.Translations = append(result.Translations, Detail{Translation: translation, Frequency: freq, Type: parsedWordType})
				}
			}
		}
	}
	return &result, nil
}

type Output struct {
	Word         string   `json:"word"`
	Infinitive   string   `json:"infinitive"`
	Translations []Detail `json:"translations"`
}

func main() {
	// word := "बन्द करना"
	// lang2 := "hi"
	// details := getDetails(word, lang2)
	// fmt.Printf("\nDetails: %v\n", details)
	// return
	flag.Parse()
	if len(*input) == 0 {
		panic("Expected input file!")
	}

	if len(*langFrom) != 2 {
		panic("Expected language with length of 2")
	}

	if len(*langTo) != 2 {
		panic("Expected language with length of 2")
	}

	r, err := os.Open(*input)
	if err != nil {
		panic(err)
	}
	defer r.Close()
	scanner := bufio.NewScanner(r)
	for scanner.Scan() {
		line := scanner.Text()
		values := strings.Split(line, "\t")
		word := values[0]
		fmt.Fprintf(os.Stderr, "Processing word: %v\n", word)
		var output *Output
		expBackoff := 1 * time.Second
		for {
			output, err = getDetails(word, *langFrom, *langTo)
			if err == nil {
				break
			} else if err.Error() == "transient" {
				fmt.Fprintf(os.Stderr, "Transient error, retrying word: %v\n", word)
				fmt.Fprint(os.Stderr, "Sleeping for: ", expBackoff, "\n")
				time.Sleep(expBackoff)
				expBackoff *= 2
				continue
			} else if err.Error() == "not ok1" {
				fmt.Fprintf(os.Stderr, "Not ok1 error, not retrying word: %v\n", word)
				break
			} else {
				panic(err)
			}
		}
		js, err := json.Marshal(output)
		if err != nil {
			panic(err)
		}
		fmt.Printf("%s\n", js)
	}
}
