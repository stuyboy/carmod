package main

import (
	"log"
	"net/http"
	"os"
	"fmt"
	"flag"
	"strings"
)

const START_DIRECTORY_END = "/server/bin"

func main() {
	// Simple static webserver:
	ip := os.Getenv("OPENSHIFT_GO_IP")
	port := os.Getenv("OPENSHIFT_GO_PORT")

	//Assume we start this within server/bin, which then needs to go back to ../../client/web
	dir := flag.String("docroot", "../../client/web2", "HTTP Docroot")
	flag.Parse()

	if ip == "" {
		ip = "localhost"
	}

	if port == "" {
		port = "8888"
	}

	cwd, cwdErr := os.Getwd()

	if cwdErr != nil {
		fmt.Println(cwdErr)
		os.Exit(1)
	}

	if !strings.HasSuffix(cwd, START_DIRECTORY_END) {
		fmt.Printf("Must be started within %v directory\n", START_DIRECTORY_END)
		os.Exit(1)
	}

	listenAddress := ip + ":" + port

	fmt.Println("listening to " + listenAddress + " with cwd " + cwd)

	log.Fatal(http.ListenAndServe(listenAddress, http.FileServer(http.Dir(*dir))))
}
