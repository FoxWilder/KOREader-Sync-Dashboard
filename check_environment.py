import sys
import subprocess
import shutil

def check():
    print("Verifying environment...")
    
    tools = ["node", "npm", "python"]
    missing = []
    
    for tool in tools:
        if shutil.which(tool) is None:
            if tool == "python" and shutil.which("python3"):
                continue
            missing.append(tool)
            
    if missing:
        print(f"Error: Missing tools: {', '.join(missing)}")
        sys.exit(1)
        
    # Check node version
    try:
        node_version = subprocess.check_output(["node", "--version"]).decode().strip()
        print(f"Node.js version: {node_version}")
        if int(node_version.split(".")[0][1:]) < 18:
            print("Warning: Sake recommends Node.js 18 or higher.")
    except:
        pass

    print("Environment check passed.")

if __name__ == "__main__":
    check()
