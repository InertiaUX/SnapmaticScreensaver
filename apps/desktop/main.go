// Snapmatic Screensaver portable launcher for Windows, Linux, and Intel Mac fallback.
// Serves the local photo feed and opens a Chromium-based browser in app/kiosk mode.
package main

import (
	"context"
	"fmt"
	"net"
	"net/http"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"runtime"
	"syscall"
	"time"
)

const port = 18765

func main() {
	webRoot, err := locateWebRoot()
	if err != nil {
		fatal(err)
	}

	ln, err := net.Listen("tcp", fmt.Sprintf("127.0.0.1:%d", port))
	if err != nil {
		fatal(fmt.Errorf("port %d in use (is Snapmatic already running?): %w", port, err))
	}

	srv := &http.Server{
		Handler: http.FileServer(http.Dir(webRoot)),
	}

	go func() {
		_ = srv.Serve(ln)
	}()

	url := fmt.Sprintf("http://127.0.0.1:%d/index.html", port)
	if err := waitReady(url, 5*time.Second); err != nil {
		_ = srv.Close()
		fatal(err)
	}

	fmt.Println("Snapmatic Screensaver")
	fmt.Println("Serving", webRoot)
	fmt.Println("Open", url)
	fmt.Println("Close the browser window or press Ctrl+C here to quit.")

	if err := openPlayer(url); err != nil {
		fmt.Fprintf(os.Stderr, "Could not launch a browser automatically: %v\n", err)
		fmt.Fprintf(os.Stderr, "Open this URL manually: %s\n", url)
	}

	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	<-ctx.Done()

	shutdown, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()
	_ = srv.Shutdown(shutdown)
}

func locateWebRoot() (string, error) {
	exe, err := os.Executable()
	if err != nil {
		return "", err
	}
	exe, err = filepath.EvalSymlinks(exe)
	if err != nil {
		return "", err
	}
	dir := filepath.Dir(exe)

	candidates := []string{
		filepath.Join(dir, "web"),
		filepath.Join(dir, "..", "web"), // e.g. Mac .app Contents/MacOS → Resources/web not used here
	}
	for _, c := range candidates {
		index := filepath.Join(c, "index.html")
		if st, err := os.Stat(index); err == nil && !st.IsDir() {
			return c, nil
		}
	}
	return "", fmt.Errorf("web/index.html not found next to the executable (%s)", dir)
}

func waitReady(url string, timeout time.Duration) error {
	deadline := time.Now().Add(timeout)
	for time.Now().Before(deadline) {
		resp, err := http.Get(url)
		if err == nil {
			resp.Body.Close()
			if resp.StatusCode == http.StatusOK {
				return nil
			}
		}
		time.Sleep(50 * time.Millisecond)
	}
	return fmt.Errorf("server did not become ready at %s", url)
}

func openPlayer(url string) error {
	switch runtime.GOOS {
	case "windows":
		return openWindows(url)
	case "darwin":
		return openDarwin(url)
	default:
		return openLinux(url)
	}
}

func openWindows(url string) error {
	// Prefer Edge/Chrome app mode for a borderless-ish player window.
	candidates := []struct {
		path string
		args []string
	}{
		{os.Getenv("ProgramFiles(x86)") + `\Microsoft\Edge\Application\msedge.exe`, []string{"--app=" + url, "--start-fullscreen", "--no-first-run"}},
		{os.Getenv("ProgramFiles") + `\Microsoft\Edge\Application\msedge.exe`, []string{"--app=" + url, "--start-fullscreen", "--no-first-run"}},
		{os.Getenv("ProgramFiles") + `\Google\Chrome\Application\chrome.exe`, []string{"--app=" + url, "--start-fullscreen", "--no-first-run"}},
		{os.Getenv("LocalAppData") + `\Google\Chrome\Application\chrome.exe`, []string{"--app=" + url, "--start-fullscreen", "--no-first-run"}},
	}
	for _, c := range candidates {
		if c.path == "" {
			continue
		}
		if _, err := os.Stat(c.path); err == nil {
			cmd := exec.Command(c.path, c.args...)
			return cmd.Start()
		}
	}
	// Fallback: default association
	cmd := exec.Command("cmd", "/c", "start", "", url)
	return cmd.Start()
}

func openDarwin(url string) error {
	chrome := "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
	if _, err := os.Stat(chrome); err == nil {
		cmd := exec.Command(chrome, "--app="+url, "--start-fullscreen", "--no-first-run")
		return cmd.Start()
	}
	cmd := exec.Command("open", url)
	return cmd.Start()
}

func openLinux(url string) error {
	browsers := []string{
		"google-chrome",
		"google-chrome-stable",
		"chromium",
		"chromium-browser",
		"microsoft-edge",
		"brave-browser",
	}
	args := []string{"--app=" + url, "--kiosk", "--no-first-run", "--disable-infobars"}
	for _, b := range browsers {
		if path, err := exec.LookPath(b); err == nil {
			cmd := exec.Command(path, args...)
			return cmd.Start()
		}
	}
	if path, err := exec.LookPath("xdg-open"); err == nil {
		return exec.Command(path, url).Start()
	}
	return fmt.Errorf("no browser found")
}

func fatal(err error) {
	fmt.Fprintf(os.Stderr, "error: %v\n", err)
	os.Exit(1)
}
