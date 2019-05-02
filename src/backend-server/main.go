package main

import (
	"context"
	"flag"
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"os"

	"github.com/go-chi/chi"
)

var (
	addrFlag = flag.String("addr", ":8081", "address to bind the backend server to")
	logFlag  = flag.String("log", "", "path to log to (empty=stderr)")
)

func serveGoodBackend(w http.ResponseWriter, r *http.Request) {
	log.Printf("[%s] %s %s", r.RemoteAddr, r.Method, r.URL)
	dbURL := "http://localhost:8002/good/db"

	req, err := http.NewRequest("GET", dbURL, nil)
	if err != nil {
		log.Printf("[%s] failed to create request for db server: %v", r.RemoteAddr, err)
		return
	}

	log.Printf("[%s] Issuing GET %s", r.RemoteAddr, dbURL)
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Printf("[%s] failed to send request to db server: %v", r.RemoteAddr, err)
		return
	}
	defer resp.Body.Close()
	log.Printf("[%s] GOT %s", r.RemoteAddr, dbURL)

	body := tryRead(resp.Body)
	if resp.StatusCode != http.StatusOK {
		log.Printf("[%s] unexpected db server response: %d\n%s", r.RemoteAddr, resp.StatusCode, body)
		return
	}

	log.Printf("[%s] db server response OK. Response body: %v", r.RemoteAddr, body)

	msg := fmt.Sprintf("BACKEND -> %v", body)
	fmt.Fprint(w, msg)
}

func tryRead(r io.Reader) string {
	b := make([]byte, 1024)
	n, _ := r.Read(b)
	return string(b[:n])
}

func main() {
	if err := run(context.Background()); err != nil {
		fmt.Fprintf(os.Stderr, "%+v\n", err)
		os.Exit(1)
	}
}

func run(ctx context.Context) (err error) {
	flag.Parse()
	log.SetPrefix("backend> ")
	log.SetFlags(log.Ltime)
	if *logFlag != "" {
		logFile, err := os.OpenFile(*logFlag, os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0644)
		if err != nil {
			return fmt.Errorf("unable to open log file: %v", err)
		}
		defer logFile.Close()
		log.SetOutput(logFile)
	} else {
		log.SetOutput(os.Stdout)
	}
	log.Printf("starting backend server...")

	ln, err := net.Listen("tcp", *addrFlag)
	if err != nil {
		return fmt.Errorf("unable to listen: %v", err)
	}
	defer ln.Close()

	r := chi.NewRouter()
	r.Use(noCache)
	r.Get("/good/backend", http.HandlerFunc(serveGoodBackend))

	log.Printf("listening on %s...", ln.Addr())
	server := &http.Server{
		Handler: r,
	}
	return server.Serve(ln)
}

func noCache(h http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-cache")
		w.Header().Set("Expires", "0")
		h.ServeHTTP(w, r)
	})
}
