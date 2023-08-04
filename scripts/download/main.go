package main

import (
	"bufio"
	"flag"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
)

var (
	input    = flag.String("input", "", "Input file")
	startIdx = flag.Int("start-idx", 0, "Start index")
)

func downloadFile(url, targetFile string) {
	// Make the HTTP GET request to fetch the image.
	resp, err := http.Get(url)
	if err != nil {
		panic(fmt.Errorf("Error fetching file %v: %v", url, err))
	}
	defer resp.Body.Close()

	// Check if the request was successful (status code 200).
	if resp.StatusCode != http.StatusOK {
		panic("Non zero status code")
	}

	// Create a new file to save the image.
	file, err := os.Create(targetFile)
	if err != nil {
		panic(err)
	}
	defer file.Close()

	// Write the response body (image content) to the file.
	_, err = io.Copy(file, resp.Body)
	if err != nil {
		panic(err)
	}
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
	idx := *startIdx
	for scanner.Scan() {
		line := scanner.Text()
		values := strings.Split(line, "\t")
		image := values[5]
		audio := values[6]
		if len(image) == 0 {
			panic("Error in string - empty image : " + line)
		}
		if len(audio) == 0 {
			panic("Error in string - empty audio : " + line)
		}
		//fmt.Printf("Image: %s\n", image)
		//fmt.Printf("Audio: %s\n", audio)
		// download image to a file image_<idx>.jpeg
		imageNew := fmt.Sprintf("image_%d.jpeg", idx)
		downloadFile(image, imageNew)
		audioNew := fmt.Sprintf("audio_%d.mp3", idx)
		downloadFile(audio, audioNew)
		idx++
		values[5] = imageNew
		values[6] = audioNew
		fmt.Printf("%s\n", strings.Join(values, "\t"))
	}
}
