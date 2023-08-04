package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"os/exec"
	"strings"
	"time"
)

func main() {
	if len(os.Args) < 2 {
		fmt.Println("Provide mode as first argument")
	}
	mode := os.Args[1]
	if mode == "convert" {
		convert()
	} else {
		download()
	}
}

func download() {
	if len(os.Args) != 3 {
		fmt.Println("Usage: go run main.go convert input_file output_file")
		return
	}

	inputFile := os.Args[2]

	// Open the input file
	inFile, err := os.Open(inputFile)
	if err != nil {
		log.Fatal("Error opening input file:", err)
	}
	defer inFile.Close()

	scanner := bufio.NewScanner(inFile)
	backoff := 1 * time.Second
	for scanner.Scan() {
		for {
			line := scanner.Text()
			parts := strings.Split(line, "\t")
			hindiWord := parts[0]
			audioId := parts[6]
			fmt.Printf("Downloading %s: %s\n", audioId, hindiWord)
			cmd := exec.Command("gtts-cli", hindiWord, "--output", fmt.Sprintf("audio_output/%s", audioId), "--lang", "hi")
			time.Sleep(backoff)
			// Set the working directory if needed
			// cmd.Dir = "/path/to/working/directory"

			// Capture the standard output and error output of the command
			cmd.Stdout = os.Stdout
			cmd.Stderr = os.Stderr

			// Start the command
			err = cmd.Run()
			if err != nil {
				backoff *= 2
				fmt.Printf("Error executing command: %v. New backoff: %v\n", err, backoff)
			} else {
				fmt.Println("Command executed successfully.")
				backoff = 1 * time.Second
				break
			}
		}
	}
}

func convert() {
	id := 0

	if len(os.Args) != 4 {
		fmt.Println("Usage: go run main.go convert input_file output_file")
		return
	}

	inputFile := os.Args[2]
	outputFile := os.Args[3]

	// Open the input file
	inFile, err := os.Open(inputFile)
	if err != nil {
		log.Fatal("Error opening input file:", err)
	}
	defer inFile.Close()

	// Open the output file
	outFile, err := os.Create(outputFile)
	if err != nil {
		log.Fatal("Error creating output file:", err)
	}
	defer outFile.Close()

	// Create a scanner to read the input file line by line
	scanner := bufio.NewScanner(inFile)

	for scanner.Scan() {
		line := scanner.Text()
		parts := strings.Split(line, "\t")

		if len(parts) < 2 {
			log.Printf("Invalid line: %s\n", line)
			continue
		}

		englishWord := parts[0]
		hindiTranslations := strings.Split(parts[1], ",")

		for _, translation := range hindiTranslations {
			// Trim any leading/trailing spaces from the translation and write to the output file
			audioId := fmt.Sprintf("audio_%d", id)
			fmt.Fprintf(outFile, "%s,%s,%s\n", strings.TrimSpace(translation), strings.TrimSpace(englishWord), audioId)
			id += 1
		}
	}

	if err := scanner.Err(); err != nil {
		log.Fatal("Error reading input file:", err)
	}

	fmt.Println("Conversion completed successfully.")
}
