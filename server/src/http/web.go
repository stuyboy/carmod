package main

import (
	"log"
	"net/http"
	"os"
	"fmt"
)

func main() {
	// Simple static webserver:
	ip := os.Getenv("OPENSHIFT_GO_IP")
	port := os.Getenv("OPENSHIFT_GO_PORT")
	relativeDir := "./client/web"
	cwd, cwdErr := os.Getwd()

	if ip == "" {
		ip = "localhost"
	}

	if port == "" {
		port = "8080"
	}

	if cwdErr != nil {
		fmt.Println(cwdErr)
		os.Exit(1)
	}

	listenAddress := ip + ":" + port

	fmt.Println("listening to " + listenAddress + " with cwd " + cwd)

	log.Fatal(http.ListenAndServe(listenAddress, http.FileServer(http.Dir(relativeDir))))
}
