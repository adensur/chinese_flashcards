package main

import (
	"bufio"
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"

	"golang.org/x/net/html"
)

var (
	input       = flag.String("input", "", "Input file")
	category    = flag.String("category", "", "Category, like Business and Industry")
	subcategory = flag.String("subcategory", "", "Sub category, like Company")
)

type MyNode struct {
	Attrs map[string]string
}

func NewNode(n *html.Node) MyNode {
	m := MyNode{}
	m.Attrs = make(map[string]string)
	for _, attr := range n.Attr {
		m.Attrs[attr.Key] = attr.Val
	}
	return m
}

func convertWordType(t string) string {
	if t == "(adj)" {
		return "adjective"
	} else if t == "(n)" {
		return "noun"
	} else if t == "(v)" {
		return "verb"
	} else if t == "(adv)" {
		return "adverb"
	} else {
		panic(fmt.Sprintf("Unknown word type: %v", t))
	}
}

type Result struct {
	HindiWord   string
	EnglishWord string
	Type        string
	Gender      string
	Examples    []string
	Image       string
	Audio       string
	Category    string
	SubCategory string
}

func newResult() Result {
	return Result{
		Category:    *category,
		SubCategory: *subcategory,
	}
}

func printResult() {
	examples := strings.Join(result.Examples, "; ")
	if strings.Contains(examples, "\t") {
		panic("Examples contain tab!")
	}
	fmt.Printf("%v\t%v\t%v\t%v\t%v\t%v\t%v\t%v\t%v\n", result.HindiWord, result.EnglishWord, result.Type, result.Gender,
		examples, result.Image, result.Audio, result.Category, result.SubCategory)
}

var result Result

func Process(n *html.Node, prefix string) {
	if n.Type == html.ElementNode {
		// fmt.Printf("Data: %v, prefix: %v\n", n.Data, prefix)
	}
	node := NewNode(n)
	if n.Data == "audio" {
		// fmt.Printf("Found an audio! Content: %v\n", node.Attrs["src"])
	}
	if n.Data == "span" && node.Attrs["lang"] == "hi" && node.Attrs["class"] == "wlv-item__word js-wlv-word" {
		// fmt.Printf("Found a span! First child's text: %v\n", n.FirstChild.Data)
	}
	// result
	// image
	if n.Data == "img" && node.Attrs["class"] == "wlv-item__image" {
		if result.HindiWord != "" {
			printResult()
		}
		result = newResult()
		imageSrc := strings.Split(node.Attrs["srcset"], " ")[0]
		result.Image = imageSrc
		// fmt.Printf("RESULT::image: %v\n", imageSrc)
	}
	// hindi word
	if n.Data == "span" && node.Attrs["lang"] == "hi" && node.Attrs["class"] == "wlv-item__word js-wlv-word" {
		result.HindiWord = n.FirstChild.Data
		// fmt.Printf("RESULT::hindi_word: %v\n", n.FirstChild.Data)
	}
	// english word
	if n.Data == "span" && node.Attrs["lang"] == "" && node.Attrs["class"] == "wlv-item__english js-wlv-english" {
		result.EnglishWord = n.FirstChild.Data
		// fmt.Printf("RESULT::english_word: %v\n", n.FirstChild.Data)
	}
	// type (noun/adjective/etc)
	if n.Data == "span" && node.Attrs["class"] == "wlv-item__word-class" {
		result.Type = convertWordType(n.FirstChild.Data)
		// fmt.Printf("RESULT::word_type: %v\n", convertWordType(n.FirstChild.Data))
	}
	// noun gender
	if n.Data == "span" && node.Attrs["class"] == "wlv-item__word-gender" {
		result.Gender = n.FirstChild.Data
		// fmt.Printf("RESULT::gender: %v\n", n.FirstChild.Data)
	}
	// hindi examples
	if n.Data == "span" && node.Attrs["class"] == "wlv-item__word" {
		data := n.FirstChild.Data
		if len(result.Examples) < 1 || data != result.Examples[0] {
			result.Examples = append(result.Examples, n.FirstChild.Data)
		}
		// fmt.Printf("RESULT::hindi_example: %v\n", n.FirstChild.Data)
	}
	// english examples
	if n.Data == "span" && node.Attrs["class"] == "wlv-item__english" {
		data := n.FirstChild.Data
		if len(result.Examples) < 2 || data != result.Examples[1] {
			result.Examples = append(result.Examples, n.FirstChild.Data)
		}
		// fmt.Printf("RESULT::english_example: %v\n", n.FirstChild.Data)
	}
	// audio
	if n.Data == "audio" && (strings.HasPrefix(prefix, "/[2]/[2]/html[25]/body[1]/div[7]/div[3]/div") ||
		strings.HasPrefix(prefix, "/[2]/[2]/html[26]/body[1]/div[7]/div[3]/div")) && strings.HasSuffix(prefix, "/div[1]/div[5]/div[1]/div[1]/div[3]/div") {
		result.Audio = node.Attrs["src"]
		// fmt.Printf("RESULT::audio %v\n", node.Attrs["src"])
	}
	idx := 0
	for c := n.FirstChild; c != nil; c = c.NextSibling {
		Process(c, fmt.Sprintf("%s[%v]/%s", prefix, idx, n.Data))
		idx += 1
	}
}

func getConjugations(word string) (*Result, error) {
	encodedWord := url.QueryEscape(word)
	url := "https://www.verbix.com/webverbix/go.php?T1=" + encodedWord + "&Submit=Go&D1=47&H1=147"
	req, err := http.NewRequest("Get", url, bytes.NewBuffer([]byte("")))
	if err != nil {
		panic(err)
	}
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
	doc, err := html.Parse(resp.Body)
	if err != nil {
		panic(err)
	}
	Process(doc, "/")
	return &result, nil
}

func main() {
	flag.Parse()
	if len(*input) == 0 {
		fmt.Printf("Expected input file!\n")
		panic("Expected input file!")
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
		expBackoff := 1 * time.Second
		var conjugations *Result
		for {
			conjugations, err = getConjugations(word)
			if err == nil {
				break
			} else if err.Error() == "transient" {
				fmt.Fprintf(os.Stderr, "Transient error, retrying word: %v\n", word)
				fmt.Fprint(os.Stderr, "Sleeping for: ", expBackoff, "\n")
				time.Sleep(expBackoff)
				expBackoff *= 2
				continue
			} else {
				panic(err)
			}
		}
		js, err := json.Marshal(conjugations)
		if err != nil {
			panic(err)
		}
		fmt.Printf("%s\n", js)
	}

}
