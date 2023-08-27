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
	url := "https://translate.google.com/_/TranslateWebserverUi/data/batchexecute?rpcids=rPsWke%2CHGRyXb%2CV11VDb&source-path=%2Fdetails&f.sid=94628587805217822&bl=boq_translate-webserver_20230813.08_p0&hl=&soc-app=1&soc-platform=1&soc-device=1&_reqid=1262696&rt=c"
	payload := "f.req=%5B%5B%5B%22rPsWke%22%2C%22%5B%5B%5C%22" + encodedWord + "%5C%22%2C%5C%22" + langFrom +
		"%5C%22%2C%5C%22" + langTo + "%5C%22%5D%2C1%5D%22%2Cnull%2C%221%22%5D%2C%5B%22HGRyXb%22%2C%22%5B%5C%22" + langFrom +
		"%5C%22%2C%5C%22" + langTo + "%5C%22%5D%22%2Cnull%2C%229%22%5D%2C%5B%22V11VDb%22%2C%22%5B%5C%22" + langFrom +
		"%5C%22%2C%5C%22" + langTo + "%5C%22%5D%22%2Cnull%2C%2212%22%5D%5D%5D&at=AFS6QyhTMeUWg72pSEGCg2YaZYOw%3A1692203095521&"
	req, err := http.NewRequest("POST", url, bytes.NewBuffer([]byte(payload)))
	if err != nil {
		panic(err)
	}

	req.Header.Add("sec-ch-ua", `"Not/A)Brand";v="99", "Google Chrome";v="115", "Chromium";v="115"`)
	req.Header.Add("X-Same-Domain", "1")
	req.Header.Add("sec-ch-ua-mobile", "?0")
	req.Header.Add("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/115.0.0.0 Safari/537.36")
	req.Header.Add("sec-ch-ua-arch", `"arm"`)
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded;charset=UTF-8")
	req.Header.Add("sec-ch-ua-full-version", `"115.0.5790.170"`)
	req.Header.Add("X-Goog-BatchExecute-Bgr", `[";Vki4SBXQAAZiAW6_QgFfSVI0DapWBfwmADkAIwj8RrOLzrt4bCMldZXoxUquFKB-XAEGEL-RzfCskTGh7LP1S03dxmk6LhNMLSHQDGqkg7CvFDwfAAAAPU8AAAAFdQEHhALmL8GPnO1zsDgBGpUU66A5zBIK5Om-4UOSipzifYxX9GHqfC5LvGrEe_Cxz3-y0PqBRN_mCfLNmW_ULuZfNTG4KnGyGQ67mvTh7eyCttJpxsIloU7M4hMNQ2N_600sNLh8gKkxUjEBViOEL4g1oYfNzRKmUBhVv1r9PzzItly8wxGQj_PaxhD8cnfJNv44A5EzNIbUjii4OtihNOWnktEcC2udTIRnVUv_UYJuLECwCKyoliakFAIgINk3yMSLW4ft9pBW9Aa4CgTlwfNGfeymPOHEvfX4jLt3fS6jkrPvevnesQ6jvVK50-tZxXEMd5i4u5ArgvCFc4A_CnQCgRL9FIL_pnXWa4WhblG7jgSy-3JvnxIBo2ZAu1sWVuaNF-7j9cO_t4Wz8PiCZOOdGR6tSOOidaGNQxjSjjWgsZPoindkpQKCL3PkMa6OYZ8TVMfIv2G7dEQpbYxrnJglhuQwNOT_vqeiQdpV_G2Vnka6UbYWJ01y9z44tx7IhYTpNh5mF6KiHPk_4nkBB70VghY82bUQ_C6EyrjljH_qwglN_fdxph-zw1y6zeIIlu8HlTceNut08T8eCxrNDVfK2g1K5dqdP44-PuLAsdN3uVbnZlEzoLCyT4i3Qv70YS29I7Z9MmjPe2oezsjIZh0xXNnfwa6DkaAwyo9RXIQKNrQcz0MkCd-Oz1IQOEgGJvmN2R2dXDH9M1NYKaQtkWiPBbcSD6uC2Ra58k8IK-qYZaKrwEOwTGaSl5UEOivX_LdMv6sXbCfBIIptVpvxEmqCrivQMKcZS0bA4UgVlMNL_z6fC7L-ny51KC29wMIjIFRiS7-17jdLUgSsFiu-4U-0piA2HBob4UjLjb6_85EzbOccAK54WHGc-ttJnFm_-r4XVUBxonFc8I6ePYt_yppd4menBdG-sR83c0ziUgH3PiLuRmXlCBvM6NUix52E1LAMpo-bzVSvh9vppVsE8oUSBCV9h1tYgIOtRg",null,null,17,null,null,null,0,"2"`)
	req.Header.Add("sec-ch-ua-platform-version", `"13.4.1"`)
	req.Header.Add("Referer", "https://translate.google.com/")
	req.Header.Add("sec-ch-ua-full-version-list", `"Not/A)Brand";v="99.0.0.0", "Google Chrome";v="115.0.5790.170", "Chromium";v="115.0.5790.170"`)
	req.Header.Add("sec-ch-ua-bitness", `"64"`)
	req.Header.Add("sec-ch-ua-model", `""`)
	req.Header.Add("sec-ch-ua-wow64", "?0")
	req.Header.Add("sec-ch-ua-platform", `"macOS"`)

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
	// fmt.Println("Response Body:")
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
