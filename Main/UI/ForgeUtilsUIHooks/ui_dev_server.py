import os
import sys
import time
import shutil
import http.server
import socketserver
import threading
from pathlib import Path
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler

# Configuration
SCRIPT_DIR = Path(__file__).parent
SOURCE_DIR = SCRIPT_DIR / "UIGameface"
TEST_FOLDER = Path(r"C:\Users\Thomas\Documents\Modding\PC2\UI Test Environment\UIGameface")
PORT = 8080

# WebSocket for live reload
import json
import hashlib
from http.server import SimpleHTTPRequestHandler

class LiveReloadHandler(SimpleHTTPRequestHandler):
    """HTTP handler that injects live reload script"""
    
    def end_headers(self):
        # Add CORS headers
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate')
        self.send_header('Expires', '0')
        super().end_headers()
    
    def do_GET(self):
        # Inject live reload script into HTML files
        if self.path.endswith('.html') or self.path == '/':
            try:
                # Get the file path
                if self.path == '/':
                    file_path = TEST_FOLDER / 'index.html'
                else:
                    file_path = TEST_FOLDER / self.path.lstrip('/')
                
                if file_path.exists():
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    
                    # Inject live reload script before </body>
                    reload_script = '''
<script>
(function() {

    // Needed for the engine to actually show our UI
    setInterval(() => {
        if (typeof engine !== 'undefined' && engine.trigger) {
            engine.trigger("Show");
        }
    }, 1000);

    let lastCheck = Date.now();
    setInterval(async () => {
        try {
            const response = await fetch('/reload-check?t=' + lastCheck);
            const data = await response.json();
            if (data.reload) {
                console.log('Changes detected, reloading...');
                location.reload();
            }
            lastCheck = Date.now();
        } catch (e) {
            console.log('Reload check failed:', e);
        }
    }, 500);
})();
</script>
'''
                    if '</body>' in content:
                        content = content.replace('</body>', reload_script + '</body>')
                    else:
                        content += reload_script
                    
                    # Send the modified content
                    self.send_response(200)
                    self.send_header('Content-type', 'text/html')
                    self.send_header('Content-Length', len(content.encode('utf-8')))
                    self.end_headers()
                    self.wfile.write(content.encode('utf-8'))
                    return
            except Exception as e:
                print(f"Error injecting reload script: {e}")
        
        # Handle reload check endpoint
        if self.path.startswith('/reload-check'):
            response = {'reload': getattr(self.server, 'needs_reload', False)}
            self.server.needs_reload = False
            
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            content = json.dumps(response).encode('utf-8')
            self.send_header('Content-Length', len(content))
            self.end_headers()
            self.wfile.write(content)
            return
        
        # Default behavior for other files
        super().do_GET()

class SyncHandler(FileSystemEventHandler):
    """Handles file system events and syncs changes"""
    
    def __init__(self, server):
        self.server = server
        self.last_modified = {}
        super().__init__()
    
    def _should_sync(self, src_path):
        """Debounce rapid fire events"""
        mtime = os.path.getmtime(src_path) if os.path.exists(src_path) else 0
        last_mtime = self.last_modified.get(src_path, 0)
        
        if mtime - last_mtime < 0.1:  # Ignore events within 100ms
            return False
        
        self.last_modified[src_path] = mtime
        return True
    
    def _sync_file(self, src_path, change_type):
        """Sync a single file to the test folder"""
        try:
            rel_path = Path(src_path).relative_to(SOURCE_DIR)
            target_path = TEST_FOLDER / rel_path
            
            print(f"[{change_type}] {rel_path}")
            
            if change_type == "Deleted":
                if target_path.exists():
                    if target_path.is_file():
                        target_path.unlink()
                    else:
                        shutil.rmtree(target_path)
                    print(f"  → Deleted")
                    self.server.needs_reload = True
            
            elif change_type in ["Created", "Modified"]:
                if os.path.exists(src_path):
                    # Create parent directory if needed
                    target_path.parent.mkdir(parents=True, exist_ok=True)
                    
                    # Copy file
                    time.sleep(0.05)  # Brief delay to ensure file is ready
                    shutil.copy2(src_path, target_path)
                    print(f"  → {'Copied' if change_type == 'Created' else 'Updated'}")
                    self.server.needs_reload = True
        
        except Exception as e:
            print(f"  → Error: {e}")
    
    def on_created(self, event):
        if not event.is_directory and self._should_sync(event.src_path):
            self._sync_file(event.src_path, "Created")
    
    def on_modified(self, event):
        if not event.is_directory and self._should_sync(event.src_path):
            self._sync_file(event.src_path, "Modified")
    
    def on_deleted(self, event):
        self._sync_file(event.src_path, "Deleted")
    
    def on_moved(self, event):
        self._sync_file(event.src_path, "Deleted")
        if not event.is_directory:
            self._sync_file(event.dest_path, "Created")

def initial_sync():
    """Perform initial sync using shutil"""
    print("Performing initial sync...")
    
    if TEST_FOLDER.exists():
        # Sync files
        for item in SOURCE_DIR.rglob('*'):
            if item.is_file():
                rel_path = item.relative_to(SOURCE_DIR)
                target = TEST_FOLDER / rel_path
                
                # Only copy if source is newer or target doesn't exist
                if not target.exists() or item.stat().st_mtime > target.stat().st_mtime:
                    target.parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(item, target)
    else:
        # Full copy if target doesn't exist
        shutil.copytree(SOURCE_DIR, TEST_FOLDER)
    
    print("Initial sync complete!\n")

def start_server(handler_class):
    """Start the HTTP server"""
    os.chdir(TEST_FOLDER)
    
    class ReusableTCPServer(socketserver.TCPServer):
        allow_reuse_address = True
        needs_reload = False
    
    with ReusableTCPServer(("127.0.0.1", PORT), handler_class) as httpd:
        print(f"Starting HTTP server at http://localhost:{PORT}")
        print(f"Watching for changes in {SOURCE_DIR}...")
        print("Press Ctrl+C to stop\n")
        
        # Start file watcher
        event_handler = SyncHandler(httpd)
        observer = Observer()
        observer.schedule(event_handler, str(SOURCE_DIR), recursive=True)
        observer.start()
        
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nStopping...")
            observer.stop()
            observer.join()
            print("Stopped.")

if __name__ == "__main__":
    # Check if watchdog is installed
    try:
        import watchdog
    except ImportError:
        print("Error: 'watchdog' package is required.")
        print("Install it with: pip install watchdog")
        sys.exit(1)
    
    # Perform initial sync
    initial_sync()
    
    # Start server with live reload
    start_server(LiveReloadHandler)