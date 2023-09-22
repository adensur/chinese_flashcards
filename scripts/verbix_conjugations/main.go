package main

import (
	"bufio"
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net/url"
	"os"
	"strings"
	"time"

	"github.com/chromedp/chromedp"
	"golang.org/x/net/html"
)

var (
	input = flag.String("input", "", "Input file")
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

var gender = ""
var isDevanagari = false
var pronoun = ""
var tense = ""
var tense2 = ""

type Result struct {
	// gender -> perfective/imperfective -> tense -> pronoun -> form
	Word         string
	Conjugations map[string]map[string]map[string]map[string]string
}

var result Result

func Process(n *html.Node, prefix string) {
	node := NewNode(n)
	if n.Type == html.ElementNode {
		// fmt.Printf("Data: %v, prefix: %v\n", n.Data, prefix)
	}
	if n.Data == "Masculine forms" && strings.HasSuffix(prefix, "/h2") {
		// fmt.Printf("Data: %v, prefix: %v\n", n.Data, prefix)
		gender = "masculine"
	}
	if n.Data == "table" && node.Attrs["class"] == "verbtense" {
		isDevanagari = true
	}
	if n.Data == "table" && node.Attrs["class"] == "verbtense nospeech" {
		isDevanagari = false
	}
	if n.Data == "Feminine forms" && strings.HasSuffix(prefix, "/h2") {
		// fmt.Printf("Data: %v, prefix: %v\n", n.Data, prefix)
		gender = "feminine"
	}
	if node.Attrs["class"] == "pronoun" && isDevanagari {
		// fmt.Printf("Data: %v, prefix: %v, attrs: %v\n", n.Data, prefix, node.Attrs)
		pronoun = n.FirstChild.Data
	}
	if n.Data == "h4" {
		// fmt.Printf("h4 Data: %v, prefix: %v, attrs: %v, first child: %s\n", n.Data, prefix, node.Attrs, n.FirstChild.Data)
		tense = n.FirstChild.Data
	}
	if n.Data == "h3" {
		// fmt.Printf("h4 Data: %v, prefix: %v, attrs: %v, first child: %s\n", n.Data, prefix, node.Attrs, n.FirstChild.Data)
		tense2 = n.FirstChild.Data
	}
	_, ok := node.Attrs["data-speech"]
	if ok && isDevanagari {
		form := n.FirstChild.Data
		if result.Conjugations == nil {
			result.Conjugations = make(map[string]map[string]map[string]map[string]string)
		}
		if result.Conjugations[gender] == nil {
			result.Conjugations[gender] = make(map[string]map[string]map[string]string)
		}
		if result.Conjugations[gender][tense2] == nil {
			result.Conjugations[gender][tense2] = make(map[string]map[string]string)
		}
		if result.Conjugations[gender][tense2][tense] == nil {
			result.Conjugations[gender][tense2][tense] = make(map[string]string)
		}
		result.Conjugations[gender][tense2][tense][pronoun] = form
		// fmt.Printf("Got form: %s, pronoun: %s, gender: %s tense: %s, tense2: %s\n", form, pronoun, gender, tense, tense2)
	}
	idx := 0
	for c := n.FirstChild; c != nil; c = c.NextSibling {
		Process(c, fmt.Sprintf("%s[%v]/%s", prefix, idx, n.Data))
		idx += 1
	}
}

func getConjugations(word string) error {
	encodedWord := url.QueryEscape(word)
	url := "https://www.verbix.com/webverbix/go.php?T1=" + encodedWord + "&Submit=Go&D1=47&H1=147"
	ctx, cancel := chromedp.NewContext(context.Background())
	defer cancel()

	// Create a timeout for the operation
	ctx, cancel = context.WithTimeout(ctx, 150*time.Second)
	defer cancel()

	var page string

	// Navigate to the page, wait for it to load, execute some JavaScript and retrieve the HTML
	err := chromedp.Run(ctx,
		chromedp.Navigate(url),
		// You can put a suitable selector that waits until some JavaScript-loaded elements are present.
		chromedp.WaitVisible(`body`, chromedp.ByQuery),
		chromedp.Evaluate(`document.body.innerHTML`, &page),
	)
	if err != nil {
		log.Fatalf("Failed getting body HTML: %v", err)
	}

	doc, err := html.Parse(strings.NewReader(page))
	if err != nil {
		return err
	}
	Process(doc, "/")
	return nil
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
		for {
			result = Result{
				Word:         word,
				Conjugations: make(map[string]map[string]map[string]map[string]string),
			}
			err = getConjugations(word)
			if err == nil {
				break
			} else if err.Error() == "transient" {
				fmt.Fprintf(os.Stderr, "Transient error, retrying word: %v\n", word)
				fmt.Fprint(os.Stderr, "Sleeping for: ", expBackoff, "\n")
				time.Sleep(expBackoff)
				expBackoff *= 2
				continue
			} else {
				fmt.Fprintf(os.Stderr, "Unknown error, retrying word: %v, err: %v\n", word, err)
				fmt.Fprint(os.Stderr, "Sleeping for: ", expBackoff, "\n")
				time.Sleep(expBackoff)
				expBackoff *= 2
				continue
			}
		}
		js, err := json.Marshal(result)
		if err != nil {
			panic(err)
		}
		fmt.Printf("%s\n", js)
	}

	flag.Parse()
	if len(*input) == 0 {
		fmt.Printf("Expected input file!\n")
		panic("Expected input file!")
	}
}
